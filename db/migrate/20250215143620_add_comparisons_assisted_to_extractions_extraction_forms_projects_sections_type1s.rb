class AddComparisonsAssistedToExtractionsExtractionFormsProjectsSectionsType1s < ActiveRecord::Migration[7.0]
  def change
    add_column :extractions_extraction_forms_projects_sections_type1s, :comparisons_assisted, :boolean, default: false
  end
end
