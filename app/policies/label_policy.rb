require_dependency 'app/policies/modules/role_checker'

class LabelPolicy < ApplicationPolicy
  extend RoleChecker

  def create?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def update?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def destroy?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def show?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = LabelPolicy.find_highest_role_id(user, record)
    highest_role && highest_role <= role
  end
end
