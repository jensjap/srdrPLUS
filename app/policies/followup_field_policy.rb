class FollowupFieldPolicy < ApplicationPolicy
  def destroy?
    project_consolidator?
  end

  def create?
    project_consolidator?
  end
end
