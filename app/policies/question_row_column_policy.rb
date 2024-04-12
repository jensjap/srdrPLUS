class QuestionRowColumnPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end

  def update?
    project_consolidator?
  end

  def destroy_entire_column?
    project_consolidator?
  end

  def answer_choices?
    project_contributor?
  end
end
