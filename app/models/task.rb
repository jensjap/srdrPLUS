class Task < ApplicationRecord
  belongs_to :task_type
  belongs_to :project

  has_many :assignments, dependent: :destroy

  accepts_nested_attributes_for :assignments
end
