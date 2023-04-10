class ResultStatisticSectionsMeasurePolicy < ApplicationPolicy
  def create?
    project_contributor?
  end
end
