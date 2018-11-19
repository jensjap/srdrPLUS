require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectsSectionPolicy < ApplicationPolicy
  extend RoleChecker

  def new?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

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

  def preview?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def dissociate_type1?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def add_quality_dimension?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = ExtractionFormsProjectsSectionPolicy.find_highest_role_id(user, record)
    highest_role && highest_role <= role
  end
end
