require_dependency 'app/policies/modules/role_checker'

class QuestionRowPolicy < ApplicationPolicy
  include RoleChecker

  def destroy?
    project_consolidator?
  end
end
