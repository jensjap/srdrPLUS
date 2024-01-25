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
end
