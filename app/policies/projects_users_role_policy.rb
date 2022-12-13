class ProjectsUsersRolePolicy < ApplicationPolicy
  def index?
    project_leader?
  end
end
