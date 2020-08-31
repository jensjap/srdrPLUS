class ResultStatisticSectionPolicy < ApplicationPolicy
  def edit?
    project_contributor?
  end

  def update?
    project_contributor?
  end

  def add_comparison?
    project_contributor?
  end

  def remove_comparison?
    project_contributor?
  end

  def consolidate?
    project_contributor?
  end
end
