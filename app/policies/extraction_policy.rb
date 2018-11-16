require_dependency 'app/policies/modules/role_checker'

class ExtractionPolicy < ApplicationPolicy
  extend RoleChecker

  class Scope < ApplicationPolicy::Scope
    def resolve
      project_ids = ProjectsUser.select(:project_id).where(user: user)
      scope.where(project_id: project_ids)
    end
  end

  def index?
    user.present?
  end

  def show?
    user.present?
  end

  def new?
    ExtractionPolicy.not_public_by_user_and_project?(user, record.project)
  end
end
