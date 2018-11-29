require_dependency 'app/policies/modules/role_checker'

class QuestionRowColumnPolicy < ApplicationPolicy
  def destroy_entire_column?
    project_consolidator?
  end

  def answer_choices?
    project_consolidator?
  end
end
