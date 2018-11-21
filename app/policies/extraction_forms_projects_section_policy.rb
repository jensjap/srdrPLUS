require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  include RoleChecker

  def new?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

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

  def preview?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def dissociate_type1?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def add_quality_dimension?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end
end
