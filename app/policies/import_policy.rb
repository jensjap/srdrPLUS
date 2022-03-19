class ImportPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end

  def import_assignments_and_mappings?
    project_leader?
  end
end
