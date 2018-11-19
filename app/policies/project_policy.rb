require_dependency 'app/policies/modules/role_checker'

class ProjectPolicy < ApplicationPolicy
  extend RoleChecker

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:projects_users).where('projects_users.user_id = ?', user.id)
    end
  end

  def index?
    ProjectsUser.where(user: user).where(project: record).exists?
  end

  def show?
    ProjectsUser.where(user: user).where(project: record).exists?
  end

  def edit?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def update?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def destroy?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def filter?
    user.present?
  end

  def undo?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def export?
    user.present?
  end

  def import_csv?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def import_pubmed?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def import_ris?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def import_endnote?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def next_assignment?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def comparison_tool?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def labeled?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  def unlabled?
    at_least?(RoleChecker::CONSOLIDATOR)
  end

  private

  def at_least?(role)
    highest_role = ExtractionPolicy.find_highest_role_id(user, record)
    highest_role && highest_role <= role
  end
end
