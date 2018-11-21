require_dependency 'app/policies/modules/role_checker'

class CitationPolicy < ApplicationPolicy
  extend RoleChecker

  def index?
    part_of_project?
  end

  def labeled?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def unlabled?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end
end
