class AbstractScreeningService
  def self.as_user?(user)
    return false if user.nil?

    (ENV['SRDRPLUS_AS_USERS'].nil? ? [] : JSON.parse(ENV['SRDRPLUS_AS_USERS'])).include?(user.id)
  end

  def self.find_asr_id_to_be_resolved(abstract_screening, user)
    unfinished_privileged_asr =
      abstract_screening
      .abstract_screening_results
      .where(user:, privileged: true, label: nil)
      .first
    return unfinished_privileged_asr if unfinished_privileged_asr

    citations_project =
      abstract_screening
      .abstract_screening_results
      .includes(:citations_project)
      .where(citations_project: { screening_status: CitationsProject::AS_IN_CONFLICT })
      .first
      &.citations_project

    return nil unless citations_project

    AbstractScreeningResult.create!(user:, abstract_screening:, citations_project:, privileged: true)
  end

  def self.find_citation_id(abstract_screening, user)
    unfinished_asr = find_unfinished_asr(abstract_screening, user)
    return unfinished_asr.citation.id if unfinished_asr

    return nil if at_or_over_limit?(abstract_screening, user)

    case abstract_screening.abstract_screening_type
    when AbstractScreening::PILOT
      get_next_pilot_citation_id(abstract_screening, user)
    when AbstractScreening::SINGLE_PERPETUAL, AbstractScreening::N_SIZE_SINGLE
      get_next_singles_citation_id(abstract_screening)
    when AbstractScreening::DOUBLE_PERPETUAL, AbstractScreening::N_SIZE_DOUBLE
      get_next_doubles_citation_id(abstract_screening, user)
    when AbstractScreening::EXPERT_NEEDED_PERPETUAL, AbstractScreening::N_SIZE_EXPERT_NEEDED
      get_next_expert_needed_citation_id(abstract_screening, user)
    when AbstractScreening::ONLY_EXPERT_NOVICE_MIXED_PERPETUAL, AbstractScreening::N_SIZE_ONLY_EXPERT_NOVICE_MIXED
      get_next_only_expert_novice_mixed_citation_id(abstract_screening, user)
    end
  end

  def self.find_or_create_asr(abstract_screening, user)
    citation_id = find_citation_id(abstract_screening, user)
    return nil if citation_id.nil?

    cp = CitationsProject.find_by(project: abstract_screening.project, citation_id:)
    AbstractScreeningResult.find_or_create_by!(abstract_screening:, user:, citations_project: cp)
  end

  def self.find_unfinished_asr(abstract_screening, user)
    AbstractScreeningResult.find_by(
      abstract_screening:,
      user:,
      label: nil
    )
  end

  def self.get_next_pilot_citation_id(abstract_screening, user)
    uniq_other_users_screened_citation_ids = other_users_screened_citation_ids(abstract_screening, user).uniq
    user_screened_citation_ids = user_screened_citation_ids(abstract_screening, user)
    unscreened_citation_ids = uniq_other_users_screened_citation_ids - user_screened_citation_ids
    citation_id = unscreened_citation_ids.sample

    if citation_id.nil?
      get_next_singles_citation_id(abstract_screening)
    else
      citation_id
    end
  end

  def self.get_next_singles_citation_id(abstract_screening)
    project_screened_citation_ids = project_screened_citation_ids(abstract_screening.project)
    non_asu_citation_ids =
      CitationsProject
      .where(project: abstract_screening.project)
      .where.not(
        screening_status: CitationsProject::AS_UNSCREENED
      )
      .map(&:citation_id)
    ineligible_citation_ids = (project_screened_citation_ids + non_asu_citation_ids).uniq
    preferred_citation = abstract_screening
                         .project
                         .citations
                         .joins('INNER JOIN citations_projects AS cp1 ON cp1.citation_id = citations.id')
                         .joins('INNER JOIN ml_predictions AS mp1 ON mp1.citations_project_id = cp1.id')
                         .joins('LEFT JOIN ml_predictions AS mp2 ON
                                   (
                                     mp1.citations_project_id = mp2.citations_project_id
                                     AND
                                     mp1.created_at < mp2.created_at
                                   )')
                         .where('mp2.id IS NULL')
                         .where.not(id: ineligible_citation_ids)
                         .where('mp1.score BETWEEN ? AND ?', 0.3, 0.7)
                         .sample

    return preferred_citation.id if preferred_citation.present?

    random_citation = abstract_screening
                      .project
                      .citations
                      .joins('INNER JOIN citations_projects AS cp2 ON cp2.citation_id = citations.id')
                      .where.not(id: ineligible_citation_ids)
                      .sample

    random_citation&.id
  end

  def self.get_next_doubles_citation_id(abstract_screening, user)
    unscreened_citation_ids =
      other_users_screened_citation_ids(abstract_screening, user) - user_screened_citation_ids(abstract_screening, user)
    citation_id = unscreened_citation_ids.tally.select { |_, v| v == 1 }.keys.sample
    if citation_id.nil?
      get_next_singles_citation_id(abstract_screening)
    else
      citation_id
    end
  end

  def self.get_next_expert_needed_citation_id(abstract_screening, user)
    if abstract_screening.project.projects_users.find { |as| as.user_id == user.id }.is_expert
      get_next_doubles_citation_id(abstract_screening, user)
    else
      unscreened_citation_ids_by_experts = expert_screened_citation_ids(abstract_screening)
      citation_id = unscreened_citation_ids_by_experts.sample
      if citation_id.nil?
        get_next_singles_citation_id(abstract_screening)
      else
        citation_id
      end
    end
  end

  def self.get_next_only_expert_novice_mixed_citation_id(abstract_screening, user)
    if abstract_screening.project.projects_users.find { |as| as.user_id == user.id }.is_expert
      unscreened_citation_ids_by_novices =
        novice_screened_citation_ids(abstract_screening)
      citation_id = unscreened_citation_ids_by_novices.sample
      if citation_id.nil?
        get_next_singles_citation_id(abstract_screening)
      else
        citation_id
      end
    else
      unscreened_citation_ids_by_experts =
        expert_screened_citation_ids(abstract_screening)
      citation_id = unscreened_citation_ids_by_experts.sample
      if citation_id.nil?
        get_next_singles_citation_id(abstract_screening)
      else
        citation_id
      end
    end
  end

  def self.other_users_screened_citation_ids(abstract_screening, user)
    abstract_screening
      .abstract_screening_results
      .includes(citations_project: :citation)
      .where
      .not(user:)
      .map(&:citation)
      .map(&:id)
  end

  def self.user_screened_citation_ids(abstract_screening, user)
    abstract_screening
      .abstract_screening_results
      .includes(citations_project: :citation)
      .where(user:)
      .map(&:citation)
      .map(&:id)
  end

  def self.expert_screened_citation_ids(abstract_screening)
    abstract_screening
      .abstract_screening_results
      .joins(:citations_project)
      .group(:citations_project_id)
      .having('count(*)=1')
      .includes(citations_project: :citation,
                user: { projects_users: :project })
      .select do |asr|
      asr.user.projects_users.any? do |pu|
        pu.is_expert && pu.project == asr.abstract_screening.project
      end
    end
      .map(&:citation)
      .map(&:id)
  end

  def self.novice_screened_citation_ids(abstract_screening)
    abstract_screening
      .abstract_screening_results
      .joins(:citations_project)
      .group(:citations_project_id)
      .having('count(*)=1')
      .includes(citations_project: :citation,
                user: { projects_users: :project })
      .select do |asr|
      asr.user.projects_users.any? do |pu|
        !pu.is_expert && pu.project == asr.abstract_screening.project
      end
    end
      .map(&:citation)
      .map(&:id)
  end

  def self.project_screened_citation_ids(project)
    CitationsProject.joins(abstract_screening_results: :abstract_screening).where(project:).map(&:citation_id)
  end

  def self.at_or_over_limit?(abstract_screening, user)
    return false unless AbstractScreening::NON_PERPETUAL.include?(abstract_screening.abstract_screening_type)

    if abstract_screening.abstract_screening_type == AbstractScreening::PILOT &&
       (abstract_screening.abstract_screening_results.where(user:).count < abstract_screening.no_of_citations)
      return false
    end

    abstract_screening
      .abstract_screening_results
      .count >= abstract_screening.no_of_citations
  end

  def self.before_asr_id(abstract_screening, asr_id, user)
    return nil if abstract_screening.blank? || asr_id.blank? || user.blank?

    AbstractScreeningResult
      .where(
        abstract_screening:,
        user:
      )
      .where(
        'updated_at < ?', AbstractScreeningResult.find_by(id: asr_id).updated_at
      ).order(:updated_at).last
  end
end
