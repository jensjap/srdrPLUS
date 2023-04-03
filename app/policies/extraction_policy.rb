class ExtractionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?

      project_ids = ProjectsUser.select(:project_id).where(user:)
      scope.where(project_id: project_ids)
    end
  end

  def index?
    project_contributor?
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
    record.assigned_to?(user) || project_leader?
  end

  def update_kqp_selections?
    record.assigned_to?(user) || project_leader?
  end

  def destroy?
    project_leader?
  end

  def work?
    return true if user.admin?

    record.assigned_to?(user) || project_leader? || project_auditor?
  end

  def comparison_tool?
    project_consolidator? || @user.admin?
  end

  def consolidate?
    project_consolidator?
  end

  def edit_type1_across_extractions?
    project_consolidator?
  end

  def reassign_extraction?
    return true if user.admin?

    record.assigned_to?(user) || project_leader?
  end
end
