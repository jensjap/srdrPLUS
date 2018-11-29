class TaskPolicy < ApplicationPolicy
  def index?
    part_of_project?
  end
end
