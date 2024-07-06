class ExternalServiceProvidersProjectsUserPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end

  def update?
    record.property_of_user?(user)
  end

  def destroy?
    record.property_of_user?(user)
  end

  def share?
    record.property_of_user?(user)
  end
end
