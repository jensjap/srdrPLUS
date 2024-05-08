class AddInstructionsToExtractionFormsProjectsSectionsType1s < ActiveRecord::Migration[7.0]
  def change
    add_column :extraction_forms_projects_sections_type1s, :instructions, :text
  end
end
