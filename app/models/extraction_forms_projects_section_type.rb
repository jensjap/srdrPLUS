class ExtractionFormsProjectsSectionType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction_forms_projects_section_type

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
