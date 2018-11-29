class ProjectsUserPolicy < ApplicationPolicy
  def next_assignment?
    project_contributor?
  end
end
