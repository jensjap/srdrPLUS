class ProjectsReasonPolicy < ApplicationPolicy
  def create?
    part_of_project?
  end

  def update?
    part_of_project?
  end

  def destroy?
    part_of_project?
  end
end
