require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionsType1RowColumnPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end
end
