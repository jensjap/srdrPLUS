require_dependency 'app/policies/modules/role_checker'

class CitationPolicy < ApplicationPolicy
  def labeled?
    project_consolidator?
  end

  def unlabled?
    project_consolidator?
  end
end
