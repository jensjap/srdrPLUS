class FulltextScreeningService < BaseScreeningService
  def self.fsr_in_fsic_count(fulltext_screening)
    CitationsProject
      .left_joins(:fulltext_screening_results)
      .where(
        project: fulltext_screening.project,
        screening_status: CitationsProject::FS_IN_CONFLICT,
        fulltext_screening_results: { fulltext_screening: }
      )
      .uniq
      .count
  end

  def self.find_fsr_to_be_resolved(fulltext_screening, user, create_record = true)
    unfinished_privileged_fsrs =
      fulltext_screening
      .fulltext_screening_results
      .includes(:citations_project)
      .where(
        privileged: true,
        label: nil,
        citations_project: { screening_status: CitationsProject::FS_IN_CONFLICT }
      )
      .order(id: :ASC)
    skipped_privileged_fsrs =
      fulltext_screening
      .fulltext_screening_results
      .includes(:citations_project)
      .where(
        privileged: true,
        label: 0,
        citations_project: { screening_status: CitationsProject::FS_IN_CONFLICT }
      )
      .order(updated_at: :ASC)
    unfinished_privileged_fsr = unfinished_privileged_fsrs.first
    return unfinished_privileged_fsr if unfinished_privileged_fsr

    citations_projects =
      CitationsProject
      .left_joins(:fulltext_screening_results)
      .where(
        project: fulltext_screening.project,
        screening_status: CitationsProject::FS_IN_CONFLICT,
        fulltext_screening_results: { fulltext_screening: }
      )
      .order('fulltext_screening_results.id ASC')
    citations_projects = citations_projects.filter do |cp|
      cp.fulltext_screening_results.none? do |fsr|
        fsr.privileged && fsr.label&.zero?
      end
    end
    if fulltext_screening.project.exclude_personal_conflicts
      citations_projects = citations_projects.filter do |cp|
        cp.fulltext_screening_results.none? do |fsr|
          fsr.user == user
        end
      end
    end
    citations_projects += skipped_privileged_fsrs.map(&:citations_project)
    citations_project = citations_projects.first

    return nil unless citations_project
    return true unless create_record

    if (fsr = FulltextScreeningResult.find_by(fulltext_screening:, citations_project:, privileged: true))
      fsr
    else
      FulltextScreeningResult.find_or_create_by!(user:, fulltext_screening:, citations_project:, privileged: true)
    end
  end

  def self.get_next_singles_citation_id(fulltext_screening)
    project_screened_citation_ids = project_screened_citation_ids(fulltext_screening.project)

    # Define the qualification types
    accepted_type = ScreeningQualification::AS_ACCEPTED
    excluded_types = [
      ScreeningQualification::FS_ACCEPTED,
      ScreeningQualification::FS_REJECTED,
      ScreeningQualification::E_ACCEPTED,
      ScreeningQualification::E_REJECTED,
      ScreeningQualification::C_ACCEPTED,
      ScreeningQualification::C_REJECTED
    ]
    project_id = fulltext_screening.project.id

    # Step 1: Find CitationsProject IDs with any of the excluded qualification types
    excluded_citations_project_ids = CitationsProject
                                     .joins(:screening_qualifications)
                                     .where(screening_qualifications: { qualification_type: excluded_types })
                                     .pluck(:id)

    # Step 2: Find CitationsProject records with AS_ACCEPTED qualifications and exclude the disqualified ones
    result = CitationsProject
             .joins(:screening_qualifications)
             .where(screening_qualifications: { qualification_type: accepted_type })
             .where(project_id:)
             .where.not(id: excluded_citations_project_ids)
             .where.not(citation_id: project_screened_citation_ids)
             .distinct

    result.sample&.citation_id
  end
end
