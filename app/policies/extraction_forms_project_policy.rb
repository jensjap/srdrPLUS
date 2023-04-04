class ExtractionFormsProjectPolicy < ApplicationPolicy
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
    project_leader? || @user.admin?
  end

  def preview?
    project_leader? || @user.admin?
  end
end
