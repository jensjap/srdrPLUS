class SdPrismaFlowPolicy < ApplicationPolicy
  def update?
    project_contributor?
  end

  def create?
    project_contributor?
  end

  def destroy?
    project_contributor?
  end
end
