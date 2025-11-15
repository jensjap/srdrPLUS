class UserPolicy
  attr_reader :user, :record

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

    @user = user
    @record = record
  end

  def new?
    ENV['NEW_USER_FORM_WHITELIST']&.split()&.map(&:to_i)&.include?(user.id) || user.admin?
  end

  def create?
    ENV['NEW_USER_FORM_WHITELIST']&.split()&.map(&:to_i)&.include?(user.id) || user.admin?
  end

  def edit?
    record.eql?(user)
  end

  def destroy?
    record.eql?(user)
  end

  def api_key_reset?
    record.eql?(user)
  end
end
