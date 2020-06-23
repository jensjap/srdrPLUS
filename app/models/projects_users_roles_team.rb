# == Schema Information
#
# Table name: projects_users_roles_teams
#
#  id                     :integer          not null, primary key
#  projects_users_role_id :integer
#  team_id                :integer
#  deleted_at             :datetime
#  active                 :boolean
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class ProjectsUsersRolesTeam < ApplicationRecord
  belongs_to :projects_users_role
  belongs_to :team

  delegate :handle, to: :projects_users_role
  delegate :project, to: :team
end
