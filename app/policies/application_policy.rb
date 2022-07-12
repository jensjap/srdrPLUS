class ApplicationPolicy
  attr_reader :user, :record

  LEADER = 'Leader'.freeze
  CONSOLIDATOR = 'Consolidator'.freeze
  CONTRIBUTOR = 'Contributor'.freeze
  AUDITOR = 'Auditor'.freeze

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, "must be logged in" unless user
    @user = user
    @record = record
  end

  def index?
    false
  end

  def show?
    false
  end

  def create?
    false
  end

  def new?
    create?
  end

  def update?
    false
  end

  def edit?
    update?
  end

  def destroy?
    false
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, "must be logged in" unless user
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  private

  def get_highest_role
    @highest_role ||= user.highest_role_in_project(record)
  end

  def project_leader?
    get_highest_role && get_highest_role == LEADER
  end

  def project_consolidator?
    get_highest_role && (
      get_highest_role == LEADER ||
      get_highest_role == CONSOLIDATOR
    )
  end

  def project_contributor?
    get_highest_role && (
      get_highest_role == LEADER ||
      get_highest_role == CONSOLIDATOR ||
      get_highest_role == CONTRIBUTOR
    )
  end

  def project_auditor?
    get_highest_role && (
      get_highest_role == LEADER ||
      get_highest_role == CONSOLIDATOR ||
      get_highest_role == CONTRIBUTOR ||
      get_highest_role == AUDITOR
    )
  end

  def part_of_project?
    get_highest_role.present?
  end

  def not_part_of_project?
    get_highest_role.nil?
  end
end
