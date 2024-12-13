class ProfilePolicy < ApplicationPolicy
  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
    @record = record
  end

  def show?
    record.user.eql?(user)
  end

  def edit?
    record.user.eql?(user)
  end

  def update?
    record.user.eql?(user)
  end

  def read_storage?
    record.user.eql?(user)
  end

  def set_storage?
    record.user.eql?(user)
  end

  def toggle_labels_visibility?
    record.user.eql?(user)
  end

  def get_labels_visibility?
    record.user.eql?(user)
  end

  def toggle_follow_project_settings?
    record.user.eql?(user)
  end

  def get_follow_project_settings?
    record.user.eql?(user)
  end
end
