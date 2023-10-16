class FulltextScreeningService < BaseScreeningService
  def self.find_fsr_id_to_be_resolved(fulltext_screening, user, create_record = true)
    unfinished_privileged_fsr =
      fulltext_screening
      .fulltext_screening_results
      .includes(:citations_project)
      .where(
        privileged: true,
        label: nil,
        citations_project: { screening_status: CitationsProject::FS_IN_CONFLICT }
      )
      .first
    return unfinished_privileged_fsr if unfinished_privileged_fsr

    citations_project =
      CitationsProject
      .left_joins(:fulltext_screening_results)
      .where(
        project: fulltext_screening.project,
        screening_status: CitationsProject::FS_IN_CONFLICT
      )
      .where.not(fulltext_screening_results: { privileged: true })
      .first

    return nil unless citations_project

    if create_record
      FulltextScreeningResult.create!(user:, fulltext_screening:, citations_project:, privileged: true)
    else
      true
    end
  end

  def self.get_next_singles_citation_id(fulltext_screening)
    project_screened_citation_ids = project_screened_citation_ids(fulltext_screening.project)
    puts project_screened_citation_ids
    CitationsProject
      .joins(:screening_qualifications)
      .where(screening_qualifications: { qualification_type: ScreeningQualification::AS_ACCEPTED })
      .where(project: fulltext_screening.project)
      .where.not(citation_id: project_screened_citation_ids)
      .sample&.citation_id
  end
end
