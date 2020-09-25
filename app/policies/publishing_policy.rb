class PublishingPolicy < ApplicationPolicy
  def new?
    @record = @record.publishable
    project_contributor?
  end

  def create?
    @record = @record.publishable
    project_contributor?
  end

  def destroy?
    @record = @record.publishable
    project_contributor?
  end
end