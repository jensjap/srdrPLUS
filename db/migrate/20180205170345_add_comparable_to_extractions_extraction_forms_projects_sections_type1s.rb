class AddComparableToExtractionsExtractionFormsProjectsSectionsType1s < ActiveRecord::Migration[5.0]
  def up
    change_table :extractions_extraction_forms_projects_sections_type1s do |t|
      t.references :comparable, polymorphic: true, index: { name: 'index_efpst1_on_comparable' }
    end
  end

  def down
    change_table :extractions_extraction_forms_projects_sections_type1s do |t|
      t.remove_references :comparable, polymorphic: true, index: { name: 'index_efpst1_on_comparable' }
    end
  end
end
