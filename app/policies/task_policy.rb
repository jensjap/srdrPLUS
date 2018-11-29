require_dependency 'app/policies/modules/role_checker'

class TaskPolicy < ApplicationPolicy
  def index?
    part_of_project?
  end
end
