require_dependency 'app/policies/modules/role_checker'

class ProjectPolicy < ApplicationPolicy
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

  def add_row?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def add_column?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def dependencies?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def toggle_dependency?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = ExtractionPolicy.find_highest_role_id(user, record.extraction_forms_projects_section.project)
    highest_role && highest_role <= role
  end
end
