class ProjectDashboardPolicy < ApplicationPolicy
  def kpis?
    part_of_project?
  end

  def citation_lifecycle_management?
    part_of_project?
  end
end
