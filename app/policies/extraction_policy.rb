require_dependency 'app/policies/modules/role_checker'

class ExtractionPolicy < ApplicationPolicy
  extend RoleChecker

  class Scope < ApplicationPolicy::Scope
    def resolve
      project_ids = ProjectsUser.select(:project_id).where(user: user)
      scope.where(project_id: project_ids)
    end
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def new?
    ExtractionPolicy.not_public_by_user_and_project?(user, record.project)
  end

  def edit?
    at_least?(RoleChecker::CONTRIBUTOR)
  end

  def create?
    at_least?(RoleChecker::CONTRIBUTOR)
  end

  def update?
    at_least?(RoleChecker::CONTRIBUTOR)
  end

  def destroy?
    at_least?(RoleChecker::CONTRIBUTOR)
  end

  def work?
    at_least?(RoleChecker::CONTRIBUTOR)
  end

  def consolidate?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def edit_type1_across_extractions?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    if record.class == Extraction::ActiveRecord_Relation
      record.all? do |r|
        highest_role = ExtractionPolicy.find_highest_role_id(user, r.project)
        highest_role && highest_role <= role
      end
    else
      highest_role = ExtractionPolicy.find_highest_role_id(user, record.project)
      highest_role && highest_role <= role
    end
  end
end
