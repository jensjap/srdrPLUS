class ScreeningQualificationPolicy < ApplicationPolicy
  def create?
    project_consolidator?
  end
end
