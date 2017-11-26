module ExtractionsExtractionFormsProjectsSectionsType1sHelper

  def is_results_section_ready?
    ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id('Arms', @extraction.id).present? &&
      ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id('Outcomes', @extraction.id).present?
  end
end
