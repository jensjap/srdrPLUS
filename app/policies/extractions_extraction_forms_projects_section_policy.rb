require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  include RoleChecker

  def update?
    at_least_project_role(RoleChecker::CONTRIBUTOR)
  end
end
