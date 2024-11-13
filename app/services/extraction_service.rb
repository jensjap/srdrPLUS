class ExtractionService
  def self.generate_status
    Extraction.includes(extractions_extraction_forms_projects_sections: :statusing).each do |extraction|
      statusings = extraction.extractions_extraction_forms_projects_sections.map(&:statusing)
      all_done =
        statusings.all? do |statusing|
          statusing.status_id == 2
        end
      next unless all_done && statusings.count.positive?

      approved_on = extraction
                                   .extractions_extraction_forms_projects_sections
                                   .map(&:statusing)
                                   .max_by(&:created_at)
                                   .created_at
      extraction.update_columns(approved_on:)
    end
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
