class MessagePolicy < ApplicationPolicy
  def index?
    case record
    when Room
      record.users.include?(user)
    when Project
      part_of_project?
    else
      false
    end
  end

  def update?
    record.user == user
  end

  def create?
    return false if record&.room&.users&.exclude?(user)
    return false if record.project && not_part_of_project?

    true
  end

  def destroy?
    record.user == user
  end
end
