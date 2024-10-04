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

  attribute :handle, type: :string

  def handle
    user.handle if association_cached?(:user) && user.association_cached?(:profile)
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

  def broadcast_help
    online_user_ids = get_redis_online_user_ids
    broadcast_user_ids =
      User.joins(:projects_users).where(projects_users: { project_id: }).pluck(:id)
    notify_users(online_user_ids & broadcast_user_ids)

    ActionCable.server.broadcast(
      help_key,
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
      }
    )
  end

  def broadcast_project_message
    ActionCable.server.broadcast(
      "project_message-#{project_id}",
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
      }
    )
  end

  def broadcast_chat
    online_user_ids = get_redis_online_user_ids
    broadcast_user_ids = room.users.map(&:id)
    notify_users(online_user_ids & broadcast_user_ids)

    bus = broadcast_user_ids.reject { |bu_id| bu_id == user.id }.map { |bu_id| { user_id: bu_id, message_id: id } }
    MessageUnread.insert_all(bus) unless bus.empty?
    (broadcast_user_ids & online_user_ids).each do |online_broadcast_user_id|
      message_unread = message_unreads.find do |mu|
        mu.user_id == online_broadcast_user_id
      end
      ActionCable.server.broadcast(
        "user_#{online_broadcast_user_id}",
        {
          message_type: 'message',
          id:,
          room:,
          user_id:,
          handle: user.handle,
          text:,
          created_at:,
          read: message_unread.blank?,
          message_unread_id: message_unread&.id,
          pinned:,
          message_id:,
          messages:,
          help_key:
        }
      )
    end
  end

  private

  def get_redis_online_user_ids
    Redis.new.pubsub('channels', 'action_cable/*')
         .map { |c| Base64.decode64(c.split('/').last) }
         .map { |string| string.split('/').last.to_i }
  end
end
