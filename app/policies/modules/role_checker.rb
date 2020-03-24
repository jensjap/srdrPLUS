module RoleChecker
  LEADER = 'Leader'.freeze
  CONSOLIDATOR = 'Consolidator'.freeze
  CONTRIBUTOR = 'Contributor'.freeze
  AUDITOR = 'Auditor'.freeze

  def get_highest_role
    @highest_role = user.highest_role_in_project(record)
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
