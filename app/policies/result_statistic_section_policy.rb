class ResultStatisticSectionPolicy < ApplicationPolicy
  def edit?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def add_comparison?
    project_consolidator?
  end

  def consolidate?
    project_consolidator?
  end
end
