require_dependency 'app/policies/modules/role_checker'

class ProjectPolicy < ApplicationPolicy
  include RoleChecker

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.joins(:projects_users).where('projects_users.user_id = ?', user.id)
    end
  end

  def edit?
    project_leader?
  end

  def update?
    project_leader?
  end

  def destroy?
    project_leader?
  end

  def undo?
    project_leader?
  end

  def import_csv?
    project_leader?
  end

  def import_pubmed?
    project_leader?
  end

  def import_ris?
    project_leader?
  end

  def import_endnote?
    project_leader?
  end

  def next_assignment?
    project_contributor?
  end
end
