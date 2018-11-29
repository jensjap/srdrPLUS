class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldPolicy < ApplicationPolicy
  def update?
    project_contributor?
  end
end
