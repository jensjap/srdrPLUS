require_dependency 'app/policies/modules/role_checker'

class QuestionRowColumnPolicy < ApplicationPolicy
  include RoleChecker

  def destroy_entire_column?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end

  def answer_choices?
    at_least_project_role?(RoleChecker::CONSOLIDATOR)
  end
end
