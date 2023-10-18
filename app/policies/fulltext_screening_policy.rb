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
    part_of_project? && (project_consolidator? || project_leader?)
  end

  def work_selection?
    part_of_project? && project_contributor? && !project_consolidator? && !project_leader?
  end

  def new?
    project_leader?
  end

  def screen?
    project_contributor?
  end

  def show?
    part_of_project?
  end

  def update?
    project_leader?
  end
end
