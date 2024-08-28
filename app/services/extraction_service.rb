class ExtractionService
  def self.generate_status
    done_extraction_ids = []
    max_statusing_created_ats = []
    Extraction.includes(extractions_extraction_forms_projects_sections: :statusing).each do |extraction|
      statusings = extraction.extractions_extraction_forms_projects_sections.map(&:statusing)
      all_done =
        statusings.all? do |statusing|
          statusing.status_id == 2
        end
      next unless all_done && statusings.count.positive?

      done_extraction_ids << extraction.id
      max_statusing_created_ats << extraction
                                   .extractions_extraction_forms_projects_sections
                                   .map(&:statusing)
                                   .max_by(&:created_at)
                                   .created_at
    end
    done_extraction_ids.zip(max_statusing_created_ats)
  end

  def self.all_eefps_done?(extraction)
    extraction.extractions_extraction_forms_projects_sections.includes(:status).map(&:status).all? do |status|
      status.name == Status::COMPLETED
    end
  end

  def self.able_to_review_status?(user, extraction)
    ApplicationPolicy.new(user, extraction).project_consolidator?
  end
end
