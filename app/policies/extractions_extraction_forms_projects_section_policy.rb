class ExtractionsExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  def update?
    project_contributor?
  end
end
