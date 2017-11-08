class ExtractionsExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :type1_type,                                    inverse_of: :extractions_extraction_forms_projects_sections_type1s, optional: true
  belongs_to :extractions_extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections_type1s
  belongs_to :type1,                                         inverse_of: :extractions_extraction_forms_projects_sections_type1s
end
