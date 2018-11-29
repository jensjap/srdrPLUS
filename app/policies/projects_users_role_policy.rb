require_dependency 'app/policies/modules/role_checker'

class ProjectsUsersRolePolicy < ApplicationPolicy
  def next_assignment?
    project_contributor?
  end

  def index?
    project_leader?
  end
end
