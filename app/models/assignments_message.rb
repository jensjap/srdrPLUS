# == Schema Information
#
# Table name: assignments_messages
#
#  id            :bigint           not null, primary key
#  assignment_id :bigint           not null
#  message_id    :bigint           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class AssignmentsMessage < ApplicationRecord
  belongs_to :assignment
  belongs_to :message
end
