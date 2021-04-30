class ExtractionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?
      project_ids = ProjectsUser.select(:project_id).where(user: user)
      scope.where(project_id: project_ids)
    end
  end

  def show?
    project_consolidator?
  end

  def new?
    part_of_project?
  end

  def edit?
    project_contributor?
  end

  def create?
    project_contributor?
  end

  def update?
    project_contributor?
  end

  def destroy?
    project_leader?
  end

  def work?
    project_contributor? || @user.admin?
  end

  def comparison_tool?
    project_consolidator?
  end

  def consolidate?
    project_consolidator?
  end

  def edit_type1_across_extractions?
    project_consolidator?
  end
end
