class KeyQuestionPolicy < ApplicationPolicy
  def index?
    project_contributor?
  end
end
