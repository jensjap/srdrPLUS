class ExtractionFormsProjectsSectionsType1Row < ApplicationRecord
  belongs_to :extraction_forms_projects_sections_type1
  belongs_to :population_name

  accepts_nested_attributes_for :population_name, reject_if: :all_blank
end
