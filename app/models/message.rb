# == Schema Information
#
# Table name: messages
#
#  id            :bigint           not null, primary key
#  message_id    :bigint
#  user_id       :bigint           not null
#  text          :text(65535)      not null
#  pinned        :boolean          default(FALSE), not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  room_id       :bigint
#  help_key      :string(255)
#  project_id    :integer
#  extraction_id :integer
#
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room, optional: true
  belongs_to :message, optional: true
  belongs_to :project, optional: true
  belongs_to :extraction, optional: true
  has_many :messages
  has_many :message_unreads, dependent: :destroy
  has_many :message_extractions, dependent: :destroy
  has_many :tagged_extractions, through: :message_extractions, source: :extraction

  attribute :handle, type: :string

  before_save :parse_extraction_tags
  after_save :associate_extractions

  def handle
    user.handle
  end

  def broadcast_message
    if help_key
      broadcast_help
      broadcast_project_message
    else
      broadcast_chat
    end
  end

  def notify_users(online_broadcast_user_ids)
    online_broadcast_user_ids.each do |online_broadcast_user_id|
      next if online_broadcast_user_id == user_id

      ActionCable.server.broadcast(
        "notification-#{online_broadcast_user_id}", { message_type: 'message', text: text.truncate(100),
                                                      url: '/' }
      )
    end
  end

  def broadcast(key, additional_data = {})
    ActionCable.server.broadcast(
      key,
      {
        message_type: 'message',
        id:,
        room:,
        user_id:,
        handle: user.handle,
        text:,
        created_at:,
        pinned:,
        message_id:,
        messages:,
        help_key:,
        project_id:,
        extraction_id:
      }.merge(additional_data)
    )
  end

  def broadcast_help
    online_user_ids = redis_online_user_ids
    broadcast_user_ids =
      User.joins(:projects_users).where(projects_users: { project_id: }).pluck(:id)
    if help_key
      broadcast_user_ids =
        (broadcast_user_ids | User.includes(:profile, :messages).where(messages: { help_key: }).pluck(:id))
    end
    notify_users(online_user_ids + broadcast_user_ids)

    broadcast(help_key)
  end

  def broadcast_project_message
    broadcast("project_message-#{project_id}")
  end

  def broadcast_chat
    online_user_ids = redis_online_user_ids
    broadcast_user_ids = room.users.map(&:id)
    notify_users(online_user_ids + broadcast_user_ids)

    bus = broadcast_user_ids.reject { |bu_id| bu_id == user.id }.map { |bu_id| { user_id: bu_id, message_id: id } }
    MessageUnread.insert_all(bus) unless bus.empty?
    (broadcast_user_ids + online_user_ids).each do |online_broadcast_user_id|
      message_unread = message_unreads.find do |mu|
        mu.user_id == online_broadcast_user_id
      end
      broadcast("user_#{online_broadcast_user_id}",
                {
                  read: message_unread.blank?,
                  message_unread_id: message_unread&.id
                })
    end
  end

  private

  def redis_online_user_ids
    Redis.new.pubsub('channels', 'action_cable/*')
         .map { |c| Base64.decode64(c.split('/').last) }
         .map { |string| string.split('/').last.to_i }
  end

  def parse_extraction_tags
    return unless text_changed?

    # Find all extraction tags in the format #123: Citation Title (Project Name)
    extraction_ids = []
    text.scan(/#(\d+):/) do |match|
      extraction_id = match[0].to_i
      # Verify the extraction exists and user has access to it
      extraction = Extraction.joins(:project, :citations_project)
                             .where(id: extraction_id)
                             .where(project: user.projects)
                             .first
      extraction_ids << extraction_id if extraction
    end

    # Store the extraction IDs to be associated after save
    @extraction_ids_to_associate = extraction_ids.uniq
  end

  def associate_extractions
    return unless @extraction_ids_to_associate

    # Clear existing associations
    message_extractions.destroy_all

    # Create new associations
    @extraction_ids_to_associate.each do |extraction_id|
      message_extractions.create!(extraction_id: extraction_id)
    end
  end
end
