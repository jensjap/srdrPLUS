class ProjectsUsersRole < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  scope :by_project, -> (project) { joins(projects_user: :project).where(projects_users: { project: project.id } ) }

  after_create :add_self_to_perpetual_task

  belongs_to :projects_user, inverse_of: :projects_users_roles
  belongs_to :role,          inverse_of: :projects_users_roles

  has_one :user, through: :projects_user
  has_one :project, through: :projects_user

  has_many :extractions, dependent: :destroy, inverse_of: :projects_users_role
  has_many :assignments, dependent: :destroy, inverse_of: :projects_users_role

  has_many :taggings, dependent: :destroy, inverse_of: :projects_users_role
  has_many :tags, through: :taggings, dependent: :destroy

  has_many :notes, dependent: :destroy, inverse_of: :projects_users_role

  def get_projects_users_role_user_information_markup
    profile = self.projects_user.user.profile
    unless profile.first_name.blank? &&
        profile.middle_name.blank? &&
        profile.last_name.blank?
      return "#{ profile.first_name } #{ profile.middle_name }. #{ profile.last_name } (#{ self.role.name })" 
    end
    return "#{ user.email } (#{ self.role.name })"
  end

  delegate :project, to: :projects_user
  delegate :user, to: :projects_user

  def add_self_to_perpetual_task
    perpetual_task = self.project.tasks.where( task_type: TaskType.find_by(name: "Perpetual")).first
    perpetual_task.assignments << Assignment.create!(projects_users_role: self, task: perpetual_task)
  end

  def handle
    "#{ user.profile.username || user.email } (#{ role.name })"
  end
end
