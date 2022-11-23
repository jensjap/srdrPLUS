class FulltextScreeningPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if FulltextScreeningPolicy.new(user, scope).project_leader?
        scope.fulltext_screenings
      else
        scope
          .fulltext_screenings
          .joins(fulltext_screenings_projects_users_roles: { projects_users_role: { projects_user: :user } })
          .where(fulltext_screenings_projects_users_roles: { projects_users_roles: { projects_users: { user: } } })
          .distinct
      end
    end
  end

  def create?
    project_leader?
  end

  def update_word_weight?
    part_of_project?
  end

  def citation_lifecycle_management?
    part_of_project?
  end

  def destroy?
    project_leader?
  end

  def edit?
    project_leader?
  end

  def index?
    part_of_project?
  end

  def kpis?
    part_of_project?
  end

  def label?
    record.nil? || record.user == user
  end

  def new?
    project_leader?
  end

  def rescreen?
    record.user == user
  end

  def screen?
    # Always allow to screen as per request.
    true
  end

  def show?
    part_of_project?
  end

  def update?
    project_leader?
  end
end
