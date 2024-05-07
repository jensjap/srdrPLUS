class QuestionRowColumnsQuestionRowColumnOptionPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end
end
