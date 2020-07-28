class ExtractionsExtractionFormsProjectsFollowupField < ApplicationRecord
  belongs_to :extractions_extraction_forms_projects_section, inverse_of: :extractions_followup_fields 
  belongs_to :followup_field, inverse_of: :extractions_followup_fields

  has_many :records, as: :recordable
end
