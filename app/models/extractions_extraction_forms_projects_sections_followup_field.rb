class ExtractionsExtractionFormsProjectsSectionsFollowupField < ApplicationRecord
  acts_as_paranoid
  belongs_to :extractions_extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields 
  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields, optional: true 
  belongs_to :followup_field, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields

  has_many :records, as: :recordable

  delegate :extraction, to: :extractions_extraction_forms_projects_section
end
