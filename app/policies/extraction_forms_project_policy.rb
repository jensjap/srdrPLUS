require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectPolicy < ApplicationPolicy
  include RoleChecker

  def edit?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def create?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def update?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def destroy?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def build?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end
end
