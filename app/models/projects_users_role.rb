class ProjectsUsersRole < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :projects_user, inverse_of: :projects_users_roles
  belongs_to :role, inverse_of: :projects_users_roles

  has_many :extractions, dependent: :destroy, inverse_of: :projects_users_role

  def get_projects_users_role_user_information_markup
    profile = self.projects_user.user.profile
    profile.first_name    + ' ' +
      profile.middle_name + '. ' +
      profile.last_name   + ' (' +
      self.role.name      + ')'
  end

  delegate :project, to: :projects_user
end
