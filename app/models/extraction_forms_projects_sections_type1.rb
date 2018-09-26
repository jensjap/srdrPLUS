class ExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_projects_section, inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1,                             inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1_type,                        inverse_of: :extraction_forms_projects_sections_type1s

  has_many :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy, inverse_of: :extraction_forms_projects_sections_type1
  has_many :timepoint_names, through: :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy

  validates :type1_id, uniqueness: { scope: :extraction_forms_projects_section_id }

  accepts_nested_attributes_for :type1, reject_if: :all_blank
  accepts_nested_attributes_for :timepoint_names, reject_if: :all_blank
end
