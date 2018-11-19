require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  extend RoleChecker

  def new?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def create?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = ExtractionPolicy.find_highest_role_id(user, record.project)
    highest_role && highest_role <= role
  end
end
