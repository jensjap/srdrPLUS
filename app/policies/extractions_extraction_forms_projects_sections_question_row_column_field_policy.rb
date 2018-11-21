require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldPolicy < ApplicationPolicy
  include RoleChecker

  def update?
    project_contributor?
  end
end
