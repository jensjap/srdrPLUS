class AssignmentPolicy < ApplicationPolicy
  def screen?
    user.present?
  end
end
