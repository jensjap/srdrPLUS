class SdOutcomePolicy < ApplicationPolicy
  def destroy?
    project_contributor?
  end
end
