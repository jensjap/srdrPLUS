class ExtractionPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?
      project_ids = ProjectsUser.select(:project_id).where(user: user)
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
    record.assigned_to?(user) ||
      ProjectsUser.find_by(project: record.project, user:).permissions.to_s(2)[-1] == '1'
  end

  def update_kqp_selections?
    record.assigned_to?(user) ||
      ProjectsUser.find_by(project: record.project, user:).permissions.to_s(2)[-1] == '1'
  end

  def destroy?
    project_leader?
  end

  def work?
    return true if user.admin?

    record.assigned_to?(user) ||
      ProjectsUser.find_by(project: record.project, user:).permissions.to_s(2)[-1] == '1' ||
      ProjectsUser.find_by(project: record.project, user:).permissions.to_s(2)[-4] == '1'
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

    record.assigned_to?(user) ||
      ProjectsUser.find_by(project: record.project, user:).permissions.to_s(2)[-1] == '1'
  end
end
