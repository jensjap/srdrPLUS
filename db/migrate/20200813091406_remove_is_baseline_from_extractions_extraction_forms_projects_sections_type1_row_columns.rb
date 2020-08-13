class RemoveIsBaselineFromExtractionsExtractionFormsProjectsSectionsType1RowColumns < ActiveRecord::Migration[5.2]
  def change
    remove_column :extractions_extraction_forms_projects_sections_type1_row_columns, :is_baseline, :boolean
  end
end
