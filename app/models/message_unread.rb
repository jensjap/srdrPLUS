# == Schema Information
#
# Table name: message_unreads
#
#  id         :bigint           not null, primary key
#  user_id    :bigint           not null
#  message_id :bigint           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class MessageUnread < ApplicationRecord
  belongs_to :message
  belongs_to :user
end
