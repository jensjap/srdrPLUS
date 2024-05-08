class AddInstructionsToExtractionFormsProjectsSections < ActiveRecord::Migration[7.0]
  def change
    add_column :extraction_forms_projects_sections, :instructions, :text
  end
end
