class FulltextScreeningPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.fulltext_screenings
    end
  end

  def create?
    project_leader?
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

  def new?
    project_leader?
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
