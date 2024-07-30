class KeyQuestionsProjectsQuestionPolicy < ApplicationPolicy
  def create?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end
end
