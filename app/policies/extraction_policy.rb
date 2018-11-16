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
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONTRIBUTOR
  end

  def create?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONTRIBUTOR
  end

  def update?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONTRIBUTOR
  end

  def destroy?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONTRIBUTOR
  end

  def work?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONTRIBUTOR
  end

  def comparison_tool?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONSOLIDATOR
  end

  def consolidate?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONSOLIDATOR
  end

  def edit_type1_across_extractions?
    ExtractionPolicy.find_highest_role_id(user, record.project) <= RoleChecker::CONSOLIDATOR
  end
end
