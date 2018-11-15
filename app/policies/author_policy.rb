class AuthorPolicy < ApplicationPolicy
  def index?
    user.present?
  end
end
