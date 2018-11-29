class ExtractionsExtractionFormsProjectsSectionsType1RowColumnPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end
end
