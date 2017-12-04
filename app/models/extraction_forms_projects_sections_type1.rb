class ExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_projects_section, inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1,                             inverse_of: :extraction_forms_projects_sections_type1s

  validates :type1_id, uniqueness: { scope: :extraction_forms_projects_section_id }
end
