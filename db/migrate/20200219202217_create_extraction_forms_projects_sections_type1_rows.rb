class CreateExtractionFormsProjectsSectionsType1Rows < ActiveRecord::Migration[5.2]
  def change
    create_table :extraction_forms_projects_sections_type1_rows do |t|
      t.references :extraction_forms_projects_sections_type1, index: { name: 'index_efpst1r_on_efpst1_id' }
      t.references :population_name, index: { name: 'index_efpst1r_on_pn_id' }

      t.timestamps
    end
  end
end
