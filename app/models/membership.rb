# == Schema Information
#
# Table name: memberships
#
#  id         :bigint           not null, primary key
#  room_id    :bigint           not null
#  user_id    :bigint           not null
#  admin      :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Membership < ApplicationRecord
  belongs_to :room
  belongs_to :user

  def broadcast_membership
    ActionCable.server.broadcast(
      "user_#{user.id}",
      {
        message_type: 'membership',
        id: room.id,
        project_id: room.project_id,
        name: room.name
      }
    )
  end
end
