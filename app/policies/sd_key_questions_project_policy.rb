class SdKeyQuestionsProjectPolicy < ApplicationPolicy
  def create?
    project_contributor?
  end

  def destroy?
    project_contributor?
  end
end
