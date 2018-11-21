require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionsType1RowPolicy < ApplicationPolicy
  include RoleChecker

  def create?
    project_contributor?
  end
end
