class AddPositionToExtractionsExtractionFormsProjectsSectionsType1RowColumns < ActiveRecord::Migration[7.0]
  def change
    add_column :extractions_extraction_forms_projects_sections_type1_row_columns, :pos, :integer, default: 999_999
  end
end
