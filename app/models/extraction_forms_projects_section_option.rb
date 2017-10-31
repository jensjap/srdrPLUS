class ExtractionFormsProjectsSectionOption < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :extraction_forms_projects_section, inverse_of: :extraction_forms_projects_section_option
end
