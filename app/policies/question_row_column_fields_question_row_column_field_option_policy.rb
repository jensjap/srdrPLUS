class QuestionRowColumnFieldsQuestionRowColumnFieldOptionPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end
end
