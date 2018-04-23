class Task < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :task_type
  belongs_to :project

  has_many :assignments, dependent: :destroy

  accepts_nested_attributes_for :assignments
end
