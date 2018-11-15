require_dependency 'app/policies/modules/role_checker'

class ProjectPolicy < ApplicationPolicy
  extend RoleChecker

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:projects_users).where('projects_users.user_id = ?', user.id)
    end
  end

  def index?
    user.present?
  end

  def show?
    ProjectsUser.where(user: user).where(project: record).exists?
  end

  def edit?
    ProjectPolicy.leader_by_user_and_project?(user, record)
  end

  def create?
    user.present?
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
end
