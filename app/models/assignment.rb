class Assignment < ApplicationRecord
  belongs_to :user
  belongs_to :task
  has_one :project, through: :task
end
