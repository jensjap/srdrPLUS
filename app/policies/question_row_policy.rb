class QuestionRowPolicy < ApplicationPolicy
  def duplicate?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end
end
