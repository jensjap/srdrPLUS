class ProjectsUsersRolesTeam < ApplicationRecord
  belongs_to :projects_users_role
  belongs_to :team
end
