class ProjectsUsersRolePolicy < ApplicationPolicy
  def next_assignment?
    project_contributor?
  end

  def index?
    project_leader?
  end
end
