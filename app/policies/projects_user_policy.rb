require_dependency 'app/policies/modules/role_checker'

class ProjectsUserPolicy < ApplicationPolicy
  include RoleChecker

  def next_assignment?
    project_contributor?
  end
end
