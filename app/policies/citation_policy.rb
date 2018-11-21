require_dependency 'app/policies/modules/role_checker'

class CitationPolicy < ApplicationPolicy
  include RoleChecker

  def labeled?
    project_consolidator?
  end

  def unlabled?
    project_consolidator?
  end
end
