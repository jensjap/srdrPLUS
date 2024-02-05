class ScreeningFormPolicy < ApplicationPolicy
  def index?
    project_leader? || @user.admin?
  end
end
