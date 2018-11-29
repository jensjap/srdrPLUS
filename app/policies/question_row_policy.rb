class QuestionRowPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end
end
