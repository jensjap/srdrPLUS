class BaseScreeningService
  def self.screening_user?(user)
    return false if user.nil?

    (ENV['SRDRPLUS_AS_USERS'].nil? ? [] : JSON.parse(ENV['SRDRPLUS_AS_USERS']))
      .include?(user.id)
  end

  def self.screening_dashboard_user?(user)
    return false if user.nil?

    (ENV['SRDRPLUS_SCREENING_DASHBOARD_USERS'].nil? ? [] : JSON.parse(ENV['SRDRPLUS_SCREENING_DASHBOARD_USERS']))
      .include?(user.id)
  end

  def self.find_citation_id(screening, user)
    unfinished_sr = find_unfinished_sr(screening, user)
    return unfinished_sr.citation.id if unfinished_sr

    return nil if at_or_over_limit?(screening, user)

    case screening.screening_type
    when screening.class.const_get('PILOT')
      get_next_pilot_citation_id(screening, user)
    when screening.class.const_get('SINGLE_PERPETUAL'), screening.class.const_get('N_SIZE_SINGLE')
      get_next_singles_citation_id(screening)
    when screening.class.const_get('DOUBLE_PERPETUAL'), screening.class.const_get('N_SIZE_DOUBLE')
      get_next_doubles_citation_id(screening, user)
    when screening.class.const_get('EXPERT_NEEDED_PERPETUAL'), screening.class.const_get('N_SIZE_EXPERT_NEEDED')
      get_next_expert_needed_citation_id(screening, user)
    when screening.class.const_get('ONLY_EXPERT_NOVICE_MIXED_PERPETUAL'), screening.class.const_get('N_SIZE_ONLY_EXPERT_NOVICE_MIXED')
      get_next_only_expert_novice_mixed_citation_id(screening, user)
    end
  end

  def self.find_next_pilot_screening(project, user)
    screenings = get_screenings(project)

    pilot_screenings = screenings.select do |screening|
      screening.screening_type == screening.class.const_get('PILOT')
    end

    exclusive_screenings = select_exclusive_user_screening(pilot_screenings, user)
    sorted_exclusive_screenings = exclusive_screenings.sort_by { |s| -s.created_at.to_i }

    sorted_exclusive_screenings.each do |screening|
      result = find_citation_id(screening, user)
      return screening unless result.nil?
    end

    remaining_screenings = pilot_screenings - exclusive_screenings
    sorted_remaining_screenings = remaining_screenings.sort_by { |s| -s.created_at.to_i }

    sorted_remaining_screenings.each do |screening|
      result = find_citation_id(screening, user)
      return screening unless result.nil?
    end

    nil
  end

  def self.find_next_non_pilot_screening(project, user)
    screenings = get_screenings(project)

    non_pilot_screenings = screenings.select do |screening|
      screening.screening_type != screening.class.const_get('PILOT')
    end

    exclusive_screenings = select_exclusive_user_screening(non_pilot_screenings, user)
    sorted_exclusive_screenings = exclusive_screenings.sort_by { |s| -s.created_at.to_i }

    sorted_exclusive_screenings.each do |screening|
      result = find_citation_id(screening, user)
      return screening unless result.nil?
    end

    remaining_screenings = non_pilot_screenings - exclusive_screenings
    single_screenings = remaining_screenings.select { |s| s.single_screening? }
    double_screenings = remaining_screenings.select { |s| s.double_screening? }

    sorted_double_screenings = double_screenings.sort_by { |s| -s.created_at.to_i }
    sorted_single_screenings = single_screenings.sort_by { |s| -s.created_at.to_i }

    sorted_double_screenings.each do |screening|
      result = find_citation_id(screening, user)
      return screening unless result.nil?
    end

    sorted_single_screenings.each do |screening|
      result = find_citation_id(screening, user)
      return screening unless result.nil?
    end

    nil
  end

  def self.select_exclusive_user_screening(screenings, user)
    exclusive_screenings = screenings.select { |item| item.exclusive_users == true }
    exclusive_screenings.select do |screening|
      screening.users.any? { |u| u.id == user.id }
    end
  end

  def self.get_screenings(project)
    project.send("#{sr_relation}s".to_sym)
  end

  def self.sr_model
    case name
    when 'AbstractScreeningService'
      AbstractScreeningResult
    when 'FulltextScreeningService'
      FulltextScreeningResult
    else
      raise "Unknown service name: #{name}"
    end
  end

  def self.sr_relation
    case name
    when 'AbstractScreeningService'
      :abstract_screening
    when 'FulltextScreeningService'
      :fulltext_screening
    else
      raise "Unknown service name: #{name}"
    end
  end

  def self.find_unfinished_sr(screening, user)
    project_id = screening.project.id
    # Exclude CitationsProject IDs with any of the excluded screening_status
    excluded_types_by_screening_status = excluded_screening_statuses
    excluded_citations_project_ids = CitationsProject
                                     .where(project_id:)
                                     .where(screening_status: excluded_types_by_screening_status)
                                     .pluck(:id)
    sr_model.where("#{sr_relation}": screening,
                   user:,
                   label: nil,
                   privileged: false)
            .where.not(citations_project_id: excluded_citations_project_ids)
            .first
  end

  def self.find_or_create_unprivileged_sr(screening, user)
    citation_id = find_citation_id(screening, user)
    return nil if citation_id.nil?

    cp = CitationsProject.find_by(project: screening.project, citation_id:)
    new_sr = nil
    sr_model.transaction do
      new_sr = sr_model.find_or_create_by!(
        "#{sr_relation}": screening,
        user:,
        citations_project: cp,
        privileged: false
      )
    end
    new_sr
  end

  def self.get_next_pilot_citation_id(screening, user)
    uniq_other_users_screened_citation_ids = other_users_screened_citation_ids(screening, user).uniq
    user_screened_citation_ids = user_screened_citation_ids(screening, user)
    unscreened_citation_ids = uniq_other_users_screened_citation_ids - user_screened_citation_ids
    citation_id = unscreened_citation_ids.sample

    if citation_id.nil?
      get_next_singles_citation_id(screening)
    else
      citation_id
    end
  end

  def self.project_screened_citation_ids(project)
    relation = "#{sr_relation}_results".to_sym
    CitationsProject.joins(relation => sr_relation.to_sym)
                    .where(project:)
                    .pluck(:citation_id)
  end

  def self.at_or_over_limit?(screening, user)
    relation = "#{sr_relation}_results".to_sym
    screening_type_method = "#{sr_relation}_type".to_sym
    model_name = name.sub('Service', '')
    non_perpetual_const = "#{model_name}::NON_PERPETUAL".constantize

    return false unless non_perpetual_const.include?(screening.send(screening_type_method))

    if screening.send(screening_type_method) == "#{model_name}::PILOT".constantize && (screening.send(relation)
                               .where(user:, privileged: false)
                               .count < screening.no_of_citations)
      return false
    end

    screening.send(relation).count >= screening.no_of_citations
  end

  def self.other_users_screened_citation_ids(screening, user)
    screening.send("#{sr_relation}_results".to_sym)
             .joins(:citations_project)
             .where(privileged: false)
             .where.not(user:)
             .pluck('citations_projects.citation_id')
  end

  def self.user_screened_citation_ids(screening, user)
    screening.send("#{sr_relation}_results".to_sym)
             .joins(:citations_project)
             .where(privileged: false)
             .where(user:)
             .pluck('citations_projects.citation_id')
  end

  def self.expert_screened_citation_ids(screening)
    screen_citation_ids_by_expertise(screening, true)
  end

  def self.novice_screened_citation_ids(screening)
    screen_citation_ids_by_expertise(screening, false)
  end

  def self.get_next_doubles_citation_id(screening, user)
    project_id = screening.project.id
    unscreened_citation_ids =
      other_users_screened_citation_ids(screening, user) - user_screened_citation_ids(screening, user)
    # Exclude CitationsProject IDs with any of the excluded screening_status
    excluded_types_by_screening_status = excluded_screening_statuses
    excluded_citations_project_ids = CitationsProject
                                     .where(project_id:)
                                     .where(screening_status: excluded_types_by_screening_status)
                                     .pluck(:id)

    citation_id =
      screening
        .send("#{sr_relation}_results".to_sym)
        .joins(:citations_project)
        .where(citations_projects: { citation_id: unscreened_citation_ids })
        .where.not(citations_project_id: excluded_citations_project_ids)
        .group(:citations_project_id)
        .having('COUNT(citations_project_id) = 1')
        .pluck(:citation_id)
        &.sample

    citation_id || get_next_singles_citation_id(screening)
  end

  def self.get_next_expert_needed_citation_id(screening, user)
    if is_user_expert?(screening, user)
      get_next_doubles_citation_id(screening, user)
    else
      unscreened_citation_ids_by_experts = expert_screened_citation_ids(screening)
      citation_id = unscreened_citation_ids_by_experts.sample
      citation_id.nil? ? get_next_singles_citation_id(screening) : citation_id
    end
  end

  def self.get_next_only_expert_novice_mixed_citation_id(screening, user)
    unscreened_citation_ids =
      if is_user_expert?(screening, user)
        novice_screened_citation_ids(screening)
      else
        expert_screened_citation_ids(screening)
      end

    citation_id = unscreened_citation_ids.sample
    citation_id.nil? ? get_next_singles_citation_id(screening) : citation_id
  end

  def self.is_user_expert?(screening, user)
    screening.project.projects_users.find { |as| as.user_id == user.id }.is_expert
  end

  def self.screen_citation_ids_by_expertise(screening, is_expert)
    screening.send("#{sr_relation}_results".to_sym)
             .joins(:citations_project)
             .group(:citations_project_id)
             .having('count(*)=1')
             .includes(citations_project: :citation,
                       user: { projects_users: :project })
             .select do |result|
               result.user.projects_users.any? do |pu|
                 pu.is_expert == is_expert && pu.project == screening.project
               end
             end
             .map { |result| result.citations_project.citation.id }
  end

  private

  def self.excluded_screening_statuses
    case name
    when 'AbstractScreeningService'
      [
        # CitationsProject::AS_UNSCREENED,
        # CitationsProject::AS_PARTIALLY_SCREENED,
        # CitationsProject::AS_IN_CONFLICT,
        CitationsProject::AS_REJECTED,
        CitationsProject::FS_UNSCREENED,
        CitationsProject::FS_PARTIALLY_SCREENED,
        CitationsProject::FS_IN_CONFLICT,
        CitationsProject::FS_REJECTED,
        CitationsProject::E_NEED_EXTRACTION,
        CitationsProject::E_IN_PROGRESS,
        CitationsProject::E_REJECTED,
        CitationsProject::E_COMPLETE,
        CitationsProject::C_NEED_CONSOLIDATION,
        CitationsProject::C_IN_PROGRESS,
        CitationsProject::C_REJECTED,
        CitationsProject::C_COMPLETE
      ]
    when 'FulltextScreeningService'
      [
        CitationsProject::AS_UNSCREENED,
        CitationsProject::AS_PARTIALLY_SCREENED,
        CitationsProject::AS_IN_CONFLICT,
        CitationsProject::AS_REJECTED,
        # CitationsProject::FS_UNSCREENED,
        # CitationsProject::FS_PARTIALLY_SCREENED,
        # CitationsProject::FS_IN_CONFLICT,
        CitationsProject::FS_REJECTED,
        CitationsProject::E_NEED_EXTRACTION,
        CitationsProject::E_IN_PROGRESS,
        CitationsProject::E_REJECTED,
        CitationsProject::E_COMPLETE,
        CitationsProject::C_NEED_CONSOLIDATION,
        CitationsProject::C_IN_PROGRESS,
        CitationsProject::C_REJECTED,
        CitationsProject::C_COMPLETE
      ]
    end
  end
end
