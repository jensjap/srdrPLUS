# == Schema Information
#
# Table name: logs
#
#  id            :bigint           not null, primary key
#  assignment_id :bigint
#  description   :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
class Log < ApplicationRecord
  belongs_to :assignment
end
