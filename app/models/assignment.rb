class Assignment < ApplicationRecord
  acts_as_paranoid
  has_paper_trail
  
  belongs_to :projects_users_role, optional: true
  belongs_to :task, optional: true
  has_one :project, through: :task

  delegate :user, to: :projects_users_role
end
