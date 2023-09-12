require_relative 'base_screening_service'

class FulltextScreeningService < BaseScreeningService

  def self.get_next_singles_citation_id(fulltext_screening)
    project_screened_citation_ids = project_screened_citation_ids(fulltext_screening.project)
    CitationsProject
      .joins(:screening_qualifications)
      .where(screening_qualifications: { qualification_type: ScreeningQualification::AS_ACCEPTED })
      .where(project: fulltext_screening.project)
      .where.not(citation_id: project_screened_citation_ids)
      .sample&.citation_id
  end

end
