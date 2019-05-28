class ProjectsUsersRolesTeam < ApplicationRecord
  belongs_to :projects_users_role
  belongs_to :team

  delegate :handle, to: :projects_users_role
  delegate :project, to: :team
end
