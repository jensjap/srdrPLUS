class MembershipPolicy < ApplicationPolicy
  def index?
    record.users.include?(user)
  end

  def create?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
