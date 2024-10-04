class ProjectMessageChannelPolicy < ApplicationPolicy
  def subscribed?
    part_of_project?
  end
end
