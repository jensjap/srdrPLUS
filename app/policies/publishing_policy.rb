class PublishingPolicy < ApplicationPolicy
  def new?
    project_contributor?
  end

  def create?
    project_contributor?
  end
end