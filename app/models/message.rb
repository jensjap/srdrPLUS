# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  message_id :bigint
#  user_id    :bigint           not null
#  room       :string(255)      not null
#  text       :string(255)      not null
#  pinned     :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Message < ApplicationRecord
  belongs_to :message, optional: true
  belongs_to :user

  has_many :message_unreads, dependent: :destroy

  after_create :broadcast_message

  private

  def broadcast_message
    type, id = room.split('-')
    online_users = ActionCable.server.connections.map(&:current_user)
    broadcast_users =
      case type
      when 'project'
        User
      .joins(projects_users: :project)
      .where(projects: { id: })
      .includes(:profile)
      .distinct
      when 'user'
        User
      .where(id: id
        .split('/'))
      .distinct
      when 'citation'
        []
      #   User
      # .joins(projects_users: { project: { citations_projects: :citation } })
      # .where(citations: { id: })
      # .includes(:profile)
      # .distinct
      when 'abstract_screening'
        User
      .joins(projects_users: { project: { abstract_screenings: { id: } } })
      .includes(:profile)
      .distinct
      when 'fulltext_screening'
        User
      .joins(projects_users: { project: { fulltext_screenings: { id: } } })
      .includes(:profile)
      .distinct
      else
        []
      end
    broadcast_users.each do |broadcast_user|
      message_unreads.create(user: broadcast_user)
    end
    (broadcast_users & online_users).each do |broadcast_user|
      message_unread = message_unreads.find do |mu|
        mu.user == broadcast_user
      end
      ActionCable.server.broadcast(
        "user_#{broadcast_user.id}",
        {
          room:,
          user_id:,
          handle: user.handle,
          text:,
          created_at:,
          read: message_unread.blank?,
          message_unread_id: message_unread&.id
        }
      )
    end
  end
end
