class ProfilePolicy < ApplicationPolicy
  def show?
    record.user == user
  end

  def edit?
    record.user == user
  end

  def update?
    record.user == user
  end
end
