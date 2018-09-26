class ExtractionFormsProjectsSectionsType1sTimepointName < ApplicationRecord
  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_projects_sections_type1
  belongs_to :timepoint_name
end
