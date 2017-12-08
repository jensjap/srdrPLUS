class Assignment < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :user
  belongs_to :task
  has_one :project, through: :task
end
