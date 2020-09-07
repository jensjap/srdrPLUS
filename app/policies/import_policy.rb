class ImportPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end
end
