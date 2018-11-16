module RoleChecker
  LEADER = 1.freeze
  CONSOLIDATOR = 2.freeze
  CONTRIBUTOR = 3.freeze
  AUDITOR = 4.freeze

  def find_highest_role_id(user, project)
    Role.
      select(:id).
      joins(:projects_users_roles).
      joins(:projects_users).
      where(projects_users_roles: { projects_users: { project: project, user: user } }).
      min.
      try(:id).
      try(:to_i)
  end

  def leader_by_user_and_project?(user, project)
    find_highest_role_id(user, project) == LEADER
  end

  def consolidator_by_user_and_project?(user, project)
    find_highest_role_id(user, project) == CONSOLIDATOR
  end

  def contributor_by_user_and_project?(user, project)
    find_highest_role_id(user, project) == CONTRIBUTOR
  end

  def auditor_by_user_and_project?(user, project)
    find_highest_role_id(user, project) == AUDITOR
  end

  def not_public_by_user_and_project?(user, project)
    find_highest_role_id(user, project).nonzero?
  end

  def public_by_user_and_project?(user, project)
    find_highest_role_id(user, project).zero?
  end
end
