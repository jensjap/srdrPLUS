class QuestionPolicy < ApplicationPolicy
  def new?
    project_consolidator?
  end

  def edit?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def destroy?
    project_consolidator?
  end

  def add_row?
    project_consolidator?
  end

  def add_column?
    project_consolidator?
  end

  def dependencies?
    project_consolidator?
  end

  def toggle_dependency?
    project_consolidator?
  end
end
