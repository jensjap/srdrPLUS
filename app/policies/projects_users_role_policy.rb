require_dependency 'app/policies/modules/role_checker'

class ProjectsUsersRolePolicy < ApplicationPolicy
  include RoleChecker

  def next_assignment?
    project_contributor?
  end
end
