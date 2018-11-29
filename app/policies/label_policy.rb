class LabelPolicy < ApplicationPolicy
  def create?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end

  def show?
    project_consolidator?
  end
end
