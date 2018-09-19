class Assignment < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :projects_users_role
  belongs_to :task
  has_one :project, through: :task

  delegate :user, to: :projects_users_role
end
