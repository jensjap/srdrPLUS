require_dependency 'app/policies/modules/role_checker'

class QuestionRowPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end
end
