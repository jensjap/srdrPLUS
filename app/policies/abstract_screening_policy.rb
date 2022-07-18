class AbstractScreeningPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      if AbstractScreeningPolicy.new(user, scope).project_leader?
        scope.abstract_screenings
      else
        scope
          .abstract_screenings
          .joins(abstract_screenings_projects_users_roles: { projects_users_role: { projects_user: :user } })
          .where(abstract_screenings_projects_users_roles: { projects_users_roles: { projects_users: { user: } } })
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
    true
  end

  def show?
    part_of_project?
  end

  def update?
    project_leader?
  end
end
