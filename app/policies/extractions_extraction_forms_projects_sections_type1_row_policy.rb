class ExtractionsExtractionFormsProjectsSectionsType1RowPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end
end
