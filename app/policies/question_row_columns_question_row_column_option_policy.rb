class QuestionRowColumnsQuestionRowColumnOptionPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end
end
