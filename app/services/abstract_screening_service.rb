class AbstractScreeningService < BaseScreeningService
  def self.asr_in_asic_count(abstract_screening)
    CitationsProject
      .left_joins(:abstract_screening_results)
      .where(
        project: abstract_screening.project,
        screening_status: CitationsProject::AS_IN_CONFLICT
      )
      .uniq
      .count
  end

  def self.find_asr_id_to_be_resolved(abstract_screening, user, create_record = true)
    unfinished_privileged_asr =
      abstract_screening
      .abstract_screening_results
      .includes(:citations_project)
      .where(
        privileged: true,
        label: nil,
        citations_project: { screening_status: CitationsProject::AS_IN_CONFLICT }
      )
      .first
    return unfinished_privileged_asr if unfinished_privileged_asr

    citations_project =
      CitationsProject
      .left_joins(:abstract_screening_results)
      .where(
        project: abstract_screening.project,
        screening_status: CitationsProject::AS_IN_CONFLICT
      )
      .where.not(abstract_screening_results: { privileged: true })
      .first

    return nil unless citations_project

    if create_record
      AbstractScreeningResult.create!(user:, abstract_screening:, citations_project:, privileged: true)
    else
      true
    end
  end

  def self.get_next_singles_citation_id(abstract_screening, x = 0)
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
                         .where('mp1.score BETWEEN ? AND ?', 0.5 - x, 0.5 + x)
                         .sample

    return preferred_citation.id if preferred_citation.present?

    highest_score_citation = abstract_screening
                             .project
                             .citations
                             .joins('INNER JOIN citations_projects AS cp2 ON cp2.citation_id = citations.id')
                             .joins('INNER JOIN ml_predictions AS mp3 ON mp3.citations_project_id = cp2.id')
                             .joins('LEFT JOIN ml_predictions AS mp4 ON
                                        (
                                          mp3.citations_project_id = mp4.citations_project_id
                                          AND
                                          mp3.created_at < mp4.created_at
                                        )')
                             .where('mp4.id IS NULL')
                             .where.not(id: ineligible_citation_ids)
                             .order('mp3.score DESC')
                             .first

    return highest_score_citation.id if highest_score_citation.present?

    random_citation = abstract_screening
                      .project
                      .citations
                      .joins('INNER JOIN citations_projects AS cp2 ON cp2.citation_id = citations.id')
                      .where.not(id: ineligible_citation_ids)
                      .sample

    random_citation&.id
  end
end
