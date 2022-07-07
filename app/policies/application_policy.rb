class ApplicationPolicy
  attr_reader :user, :record

  LEADER = 'Leader'.freeze
  CONSOLIDATOR = 'Consolidator'.freeze
  CONTRIBUTOR = 'Contributor'.freeze
  AUDITOR = 'Auditor'.freeze

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      raise Pundit::NotAuthorizedError, 'must be logged in' unless user

      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end
  end

  def initialize(user, record)
    raise Pundit::NotAuthorizedError, 'must be logged in' unless user

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

  def highest_role
    @highest_role ||= user.highest_role_in_project(record)
  end

  def project_leader?
    highest_role && highest_role == LEADER
  end

  def project_consolidator?
    highest_role && (
      highest_role == LEADER ||
      highest_role == CONSOLIDATOR
    )
  end

  def project_contributor?
    highest_role && (
      highest_role == LEADER ||
      highest_role == CONSOLIDATOR ||
      highest_role == CONTRIBUTOR
    )
  end

  def project_auditor?
    highest_role && (
      highest_role == LEADER ||
      highest_role == CONSOLIDATOR ||
      highest_role == CONTRIBUTOR ||
      highest_role == AUDITOR
    )
  end

  def part_of_project?
    highest_role.present?
  end

  def not_part_of_project?
    highest_role.nil?
  end
end
