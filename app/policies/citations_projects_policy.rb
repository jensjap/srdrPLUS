class CitationsProjectsPolicy < ApplicationPolicy
  def update_evaluation?
    project_leader?
  end
end
