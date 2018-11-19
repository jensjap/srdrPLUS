require_dependency 'app/policies/modules/role_checker'

class ResultStatisticSectionPolicy < ApplicationPolicy
  extend RoleChecker

  def edit?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def update?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def add_comparison?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def consolidate?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = ResultStatisticSectionPolicy.find_highest_role_id(user, record)
    highest_role && highest_role <= role
  end
end
