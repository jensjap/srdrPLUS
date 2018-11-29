require_dependency 'app/policies/modules/role_checker'

class QuestionRowColumnFieldsQuestionRowColumnFieldOptionPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end
end
