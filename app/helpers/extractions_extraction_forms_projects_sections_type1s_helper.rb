module ExtractionsExtractionFormsProjectsSectionsType1sHelper

  def make_results_section_available?(extraction_id, extraction_forms_project_id)
    ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id_and_extraction_forms_project_id('Arms', extraction_id, extraction_forms_project_id).present? &&
      ExtractionsExtractionFormsProjectsSectionsType1.by_section_name_and_extraction_id_and_extraction_forms_project_id('Outcomes', extraction_id, extraction_forms_project_id).present?
  end
end
