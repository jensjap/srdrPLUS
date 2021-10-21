# == Schema Information
#
# Table name: projects_users_roles
#
#  id               :integer          not null, primary key
#  projects_user_id :integer
#  role_id          :integer
#  deleted_at       :datetime
#  active           :boolean
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class ProjectsUsersRole < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true

  scope :by_project, -> (project) { joins(projects_user: :project).where(projects_users: { project: project.id } ) }

  after_create :add_self_to_perpetual_task

  belongs_to :projects_user, inverse_of: :projects_users_roles
  belongs_to :role,          inverse_of: :projects_users_roles

  has_one :user, through: :projects_user
  has_one :project, through: :projects_user

  has_many :assignments, dependent: :destroy, inverse_of: :projects_users_role
  has_many :extractions, inverse_of: :projects_users_role

  has_many :projects_users_roles_teams
  has_many :teams, through: :projects_users_roles_teams, dependent: :destroy

  has_many :taggings, dependent: :destroy, inverse_of: :projects_users_role
  has_many :tags, through: :taggings, dependent: :destroy

  has_many :notes, dependent: :destroy, inverse_of: :projects_users_role

  before_destroy :reassign_extraction

  delegate :project, to: :projects_user
  delegate :user, to: :projects_user

  def add_self_to_perpetual_task
    perpetual_task = self.project.tasks.where( task_type: TaskType.find_by(name: "Perpetual")).first
    perpetual_task.assignments << Assignment.create!(projects_users_role: self, task: perpetual_task)
  end

  def handle
    "#{ user.username || user.email } (#{ role.name })"
  end

  private
    def reassign_extraction
      extractions.each do |extraction|
        new_assignee = ProjectsUsersRole.
          joins(:projects_user).
          where(projects_users: { project: extraction.project }, role_id: 1).
          where.
          not(id: self.id).
          first
        extraction.update!(projects_users_role: new_assignee) if new_assignee
      end
    end
end
