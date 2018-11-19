require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectPolicy < ApplicationPolicy
  extend RoleChecker

  def edit?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def create?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def update?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def destroy?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def build?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = KeyQuestionsProjectPolicy.find_highest_role_id(user, record.project)
    highest_role && highest_role <= role
  end
end
