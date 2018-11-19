require_dependency 'app/policies/modules/role_checker'

class ExtractionsExtractionFormsProjectsSectionsType1Policy < ApplicationPolicy
  extend RoleChecker

  def edit?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def update?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def destroy?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def edit_timepoints?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def edit_populations?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def add_population?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def get_results_populations?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = ExtractionsExtractionFormsProjectsSectionsType1Policy.find_highest_role_id(user, record)
    highest_role && highest_role <= role
  end
end
