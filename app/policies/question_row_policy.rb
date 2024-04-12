class QuestionRowPolicy < ApplicationPolicy
  def duplicate?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end
end
