require_dependency 'app/policies/modules/role_checker'

class NotePolicy < ApplicationPolicy
  def destroy?
    project_contributor?
  end

  def create?
    project_contributor?
  end
end
