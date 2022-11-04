class SdMetaDatumPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test?
      scope.where(project_id: user.projects.pluck(:id))
    end
  end

  def index?
    project_auditor?
  end

  def show?
    project_auditor?
  end

  def create?
    project_contributor?
  end

  def edit?
    project_contributor?
  end

  def update?
    project_contributor?
  end

  def destroy?
    project_contributor?
  end

  def mapping_update?
    project_contributor?
  end

  def preview?
    project_contributor?
  end

  def section_update?
    project_contributor?
  end
end
