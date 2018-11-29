class ProjectPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?
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

  def export?
    project_contributor?
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
