module RoleChecker
  LEADER = 1.freeze
  CONSOLIDATOR = 2.freeze
  CONTRIBUTOR = 3.freeze
  AUDITOR = 4.freeze

  def get_highest_role_id
    Role.
      select(:id).
      joins(:projects_users_roles).
      joins(:projects_users).
      where(projects_users_roles: { projects_users: { project: record, user: user } }).
      min.
      try(:id).
      try(:to_i)
  end

  def project_leader?
    get_highest_role_id == LEADER
  end

  def project_consolidator?
    get_highest_role_id == CONSOLIDATOR
  end

  def project_contributor?
    get_highest_role_id == CONTRIBUTOR
  end

  def project_auditor?
    get_highest_role_id == AUDITOR
  end

  def part_of_project?
    get_highest_role_id.present?
  end

  def not_part_of_project?
    get_highest_role_id.nil?
  end

  def at_least_project_role?(role)
    highest_role = get_highest_role_id
    highest_role && highest_role <= role
  end
end
