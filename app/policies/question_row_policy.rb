require_dependency 'app/policies/modules/role_checker'

class QuestionRowPolicy < ApplicationPolicy
  include RoleChecker

  def destroy?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end
end
