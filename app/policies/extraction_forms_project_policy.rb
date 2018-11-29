require_dependency 'app/policies/modules/role_checker'

class ExtractionFormsProjectPolicy < ApplicationPolicy
  include RoleChecker

  def edit?
    project_leader?
  end

  def create?
    project_leader?
  end

  def update?
    project_leader?
  end

  def destroy?
    project_leader?
  end

  def build?
    project_leader?
  end
end
