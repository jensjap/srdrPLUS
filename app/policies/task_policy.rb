require_dependency 'app/policies/modules/role_checker'

class TaskPolicy < ApplicationPolicy
  include RoleChecker

  def index?
    part_of_project?
  end
end
