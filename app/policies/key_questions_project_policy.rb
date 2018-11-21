require_dependency 'app/policies/modules/role_checker'

class KeyQuestionsProjectPolicy < ApplicationPolicy
  include RoleChecker

  def edit?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end
end
