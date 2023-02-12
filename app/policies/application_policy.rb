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
    @projects_user = ProjectsUser.find_by(user:, project: record)
    @permissions = @projects_user.try(:permissions) || 0
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

  def project_leader?
    @projects_user.project_leader?
  end

  def project_consolidator?
    @projects_user.project_consolidator?
  end

  def project_contributor?
    @projects_user.project_contributor?
  end

  def project_auditor?
    @projects_user.project_auditor?
  end

  def part_of_project?
    !not_part_of_project?
  end

  def not_part_of_project?
    @projects_user.nil?
  end
end
