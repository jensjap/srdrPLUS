class FulltextScreeningService
  def self.find_citation_id(fulltext_screening, user)
    unfinished_fsr = find_unfinished_fsr(fulltext_screening, user)
    return unfinished_fsr.citation.id if unfinished_fsr

    return nil if at_or_over_limit?(fulltext_screening, user)

    case fulltext_screening.fulltext_screening_type
    when FulltextScreening::PILOT
      get_next_pilot_citation_id(fulltext_screening, user)
    when FulltextScreening::SINGLE_PERPETUAL, FulltextScreening::N_SIZE_SINGLE
      get_next_singles_citation_id(fulltext_screening)
    when FulltextScreening::DOUBLE_PERPETUAL, FulltextScreening::N_SIZE_DOUBLE
      get_next_doubles_citation_id(fulltext_screening, user)
    end
  end

  def self.find_or_create_unprivileged_fsr(fulltext_screening, user)
    citation_id = find_citation_id(fulltext_screening, user)
    return nil if citation_id.nil?

    cp = CitationsProject.find_by(project: fulltext_screening.project, citation_id:)
    FulltextScreeningResult.find_or_create_by!(
      fulltext_screening:,
      user:,
      citations_project: cp,
      privileged: false
    )
  end

  def self.find_unfinished_fsr(fulltext_screening, user)
    FulltextScreeningResult.find_by(
      fulltext_screening:,
      user:,
      label: nil
    )
  end

  def self.get_next_pilot_citation_id(fulltext_screening, user)
    uniq_other_users_screened_citation_ids = other_users_screened_citation_ids(fulltext_screening, user).uniq
    user_screened_citation_ids = user_screened_citation_ids(fulltext_screening, user)
    unscreened_citation_ids = uniq_other_users_screened_citation_ids - user_screened_citation_ids
    citation_id = unscreened_citation_ids.sample

    if citation_id.nil?
      get_next_singles_citation_id(fulltext_screening)
    else
      citation_id
    end
  end

  def self.get_next_singles_citation_id(fulltext_screening)
    project_screened_citation_ids = project_screened_citation_ids(fulltext_screening.project)
    CitationsProject
      .joins(:screening_qualifications)
      .where(screening_qualifications: { qualification_type: ScreeningQualification::AS_ACCEPTED })
      .where(project: fulltext_screening.project)
      .where.not(citation_id: project_screened_citation_ids)
      .sample&.citation_id
  end

  def self.get_next_doubles_citation_id(fulltext_screening, user)
    unscreened_citation_ids =
      other_users_screened_citation_ids(fulltext_screening, user) - user_screened_citation_ids(fulltext_screening, user)
    citation_id = unscreened_citation_ids.tally.select { |_, v| v == 1 }.keys.sample
    if citation_id.nil?
      get_next_singles_citation_id(fulltext_screening)
    else
      citation_id
    end
  end

  def self.other_users_screened_citation_ids(fulltext_screening, user)
    fulltext_screening.fulltext_screening_results.where.not(user:).map(&:citation).map(&:id)
  end

  def self.user_screened_citation_ids(fulltext_screening, user)
    fulltext_screening.fulltext_screening_results.where(user:).map(&:citation).map(&:id)
  end

  def self.project_screened_citation_ids(project)
    CitationsProject.joins(fulltext_screening_results: :fulltext_screening).where(project:).map(&:citation_id)
  end

  def self.at_or_over_limit?(fulltext_screening, user)
    return false unless FulltextScreening::NON_PERPETUAL.include?(fulltext_screening.fulltext_screening_type)

    if fulltext_screening.fulltext_screening_type == FulltextScreening::PILOT &&
       (fulltext_screening.fulltext_screening_results.where(user:, privileged: false).count < fulltext_screening.no_of_citations)
      return false
    end

    fulltext_screening
      .fulltext_screening_results
      .count >= fulltext_screening.no_of_citations
  end

  def self.before_fsr_id(fulltext_screening, fsr_id, user)
    return nil if fulltext_screening.blank? || fsr_id.blank? || user.blank?

    FulltextScreeningResult
      .where(
        fulltext_screening:,
        user:
      )
      .where(
        'updated_at < ?', FulltextScreeningResult.find_by(id: fsr_id).updated_at
      ).order(:updated_at).last
  end
end
