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
    @permissions.to_s(2)[-1] == '1'
  end

  def project_consolidator?
    project_leader? || @permissions.to_s(2)[-2] == '1'
  end

  def project_contributor?
    project_leader? || project_consolidator? || @permissions.to_s(2)[-3] == '1'
  end

  def project_auditor?
    project_leader? || project_consolidator? || project_contributor? || @permissions.to_s(2)[-4] == '1'
  end

  def part_of_project?
    !not_part_of_project?
  end

  def not_part_of_project?
    @permissions.zero?
  end
end
