class PublishingPolicy < ApplicationPolicy
  def new?
    project_contributor? || @user.admin?
  end

  def create?
    project_contributor? || @user.admin?
  end
end