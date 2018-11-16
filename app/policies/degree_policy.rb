class DegreePolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
