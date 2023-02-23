class ConsolidationPolicy < ApplicationPolicy
  def index?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end

  def show?
    project_consolidator?
  end
end
