# == Schema Information
#
# Table name: task_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class TaskType < ApplicationRecord
    has_many :tasks
end
