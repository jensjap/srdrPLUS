require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  def update?
    project_contributor?
  end
end
