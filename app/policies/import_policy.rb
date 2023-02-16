class ImportPolicy < ApplicationPolicy
  def index?
    project_auditor?
  end

  def show?
    project_contributor?
  end

  def start?
    project_contributor?
  end

  def create?
    project_contributor?
  end

  def import_assignments_and_mappings?
    project_leader?
  end

  def simple_import?
    project_leader?
  end
end
