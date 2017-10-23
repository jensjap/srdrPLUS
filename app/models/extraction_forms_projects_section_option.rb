class ExtractionFormsProjectsSectionOption < ApplicationRecord
  acts_as_paranoid

  belongs_to :extraction_forms_projects_section
end
