require_dependency 'app/policies/modules/role_checker'

class ExtractionPolicy < ApplicationPolicy
  include RoleChecker

  class Scope < ApplicationPolicy::Scope
    def resolve
      project_ids = ProjectsUser.select(:project_id).where(user: user)
      scope.where(project_id: project_ids)
    end
  end

  def new?
    part_of_project?
  end

  def edit?
    at_least_project_role?(RoleChecker::CONTRIBUTOR)
  end

  def create?
    at_least_project_role?(RoleChecker::CONTRIBUTOR)
  end

  def update?
    at_least_project_role?(RoleChecker::CONTRIBUTOR)
  end

  def destroy?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def work?
    at_least_project_role?(RoleChecker::CONTRIBUTOR)
  end

  def comparison_tool?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def consolidate?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def edit_type1_across_extractions?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end
end
