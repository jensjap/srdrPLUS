class BaseScreeningService
  def self.find_citation_id(screening, user)
    service_name = self.name
    model, relation_name = determine_sr_model_and_relation(service_name)
    unfinished_sr = find_unfinished_sr(screening, user, model, relation_name)
    return unfinished_sr.citation.id if unfinished_sr

    return nil if at_or_over_limit?(screening, user)

    case screening.screening_type
    when :pilot
        get_next_pilot_citation_id(screening, user)
    when :single_perpetual, :n_size_single
        get_next_singles_citation_id(screening)
    when :double_perpetual, :n_size_double
        get_next_doubles_citation_id(screening, user)
    when :expert_needed_perpetual, :n_size_expert_needed
        get_next_expert_needed_citation_id(screening, user)
    when :only_expert_novice_mixed_perpetual, :n_size_only_expert_novice_mixed
        get_next_only_expert_novice_mixed_citation_id(screening, user)
    end
  end

  def self.determine_sr_model_and_relation(service_name)
    case service_name
    when 'AbstractScreeningService'
      return [AbstractScreeningResult, :abstract_screening]
    when 'FulltextScreeningService'
      return [FulltextScreeningResult, :fulltext_screening]
    else
      raise "Unknown service name: #{service_name}"
    end
  end

  def self.find_unfinished_sr(screening, user, model, relation_name)
    model.find_by(
      "#{relation_name}": screening,
      user: user,
      label: nil,
      privileged: false
    )
  end

  def self.find_or_create_unprivileged_sr(screening, user)
    service_name = self.name
    model, relation_name = determine_sr_model_and_relation(service_name)

    citation_id = find_citation_id(screening, user)
    return nil if citation_id.nil?

    cp = CitationsProject.find_by(project: screening.project, citation_id: citation_id)
    model.find_or_create_by!(
      "#{relation_name}": screening,
      user: user,
      citations_project: cp,
      privileged: false
    )
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
    service_name = self.name
    _, relation_name = determine_sr_model_and_relation(service_name)

    relation = "#{relation_name}_results".to_sym
    CitationsProject.joins(relation => relation_name.to_sym)
                    .where(project: project)
                    .map(&:citation_id)
  end

  def self.at_or_over_limit?(screening, user)
    service_name = self.name
    _, relation_name = determine_sr_model_and_relation(service_name)

    relation = "#{relation_name}_results".to_sym
    screening_type_method = "#{relation_name}_type".to_sym
    non_perpetual_const = "#{service_name}::NON_PERPETUAL".constantize

    return false unless non_perpetual_const.include?(screening.send(screening_type_method))

    if screening.send(screening_type_method) == "#{service_name}::PILOT".constantize
      return false if screening.send(relation)
                             .where(user: user, privileged: false)
                             .count < screening.no_of_citations
    end

    screening.send(relation).count >= screening.no_of_citations
  end

  def self.other_users_screened_citation_ids(screening, user)
    service_name = self.name
    _, relation_name = determine_sr_model_and_relation(service_name)

    relation = "#{relation_name}_results".to_sym
    screening.send(relation)
             .includes(citations_project: :citation)
             .where(privileged: false)
             .where.not(user: user)
             .map(&:citation)
             .map(&:id)
  end

  def self.user_screened_citation_ids(screening, user)
    service_name = self.name
    _, relation_name = determine_sr_model_and_relation(service_name)

    relation = "#{relation_name}_results".to_sym
    screening.send(relation)
             .includes(citations_project: :citation)
             .where(privileged: false, user: user)
             .map(&:citation)
             .map(&:id)
  end

  def self.expert_screened_citation_ids(screening)
    screen_citation_ids_by_expertise(screening, true)
  end

  def self.novice_screened_citation_ids(screening)
    screen_citation_ids_by_expertise(screening, false)
  end

  def self.get_next_doubles_citation_id(screening, user)
    unscreened_citation_ids =
      other_users_screened_citation_ids(screening, user) - user_screened_citation_ids(screening, user)
    citation_id = unscreened_citation_ids.tally.select { |_, v| v == 1 }.keys.sample
    if citation_id.nil?
      get_next_singles_citation_id(screening)
    else
      citation_id
    end
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

  private

  def self.screen_citation_ids_by_expertise(screening, is_expert)
    service_name = self.name
    _, relation_name = determine_sr_model_and_relation(service_name)

    relation = "#{relation_name}_results".to_sym
    screening.send(relation)
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
             .map(&:citation)
             .map(&:id)
  end
end