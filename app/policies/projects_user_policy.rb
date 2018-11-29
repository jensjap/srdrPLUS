require_dependency 'app/policies/modules/role_checker'

class ProjectsUserPolicy < ApplicationPolicy
  def next_assignment?
    project_contributor?
  end
end
