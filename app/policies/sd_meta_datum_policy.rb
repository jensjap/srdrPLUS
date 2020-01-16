class SdMetaDatumPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      return scope.all if Rails.env.test? 
      scope.where(project_id: user.projects.pluck(:id))
    end
  end

  def edit?
    project_contributor?
  end

  def update?
    project_contributor?
  end
end
