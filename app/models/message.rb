# == Schema Information
#
# Table name: messages
#
#  id         :bigint           not null, primary key
#  message_id :bigint
#  user_id    :bigint           not null
#  text       :text(65535)      not null
#  pinned     :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  room_id    :bigint
#
class Message < ApplicationRecord
  belongs_to :user
  belongs_to :room
  belongs_to :message, optional: true
  has_many :messages

  has_many :message_unreads, dependent: :destroy

  def broadcast_message
    online_users = ActionCable.server.connections.map(&:current_user)
    broadcast_users = room.users
    bus = broadcast_users.reject { |bu| bu == user }.map { |bu| { user_id: bu.id, message_id: id } }
    MessageUnread.insert_all(bus) unless bus.empty?
    (broadcast_users & online_users).each do |broadcast_user|
      message_unread = message_unreads.find do |mu|
        mu.user_id == broadcast_user.id
      end
      ActionCable.server.broadcast(
        "user_#{broadcast_user.id}",
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
          messages:
        }
      )
    end
  end
end
