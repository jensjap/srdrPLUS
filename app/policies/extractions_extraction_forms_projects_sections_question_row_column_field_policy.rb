require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldPolicy < ApplicationPolicy
  def update?
    project_contributor?
  end
end
