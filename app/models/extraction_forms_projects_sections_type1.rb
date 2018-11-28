class ExtractionFormsProjectsSectionsType1 < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_projects_section, inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1,                             inverse_of: :extraction_forms_projects_sections_type1s
  belongs_to :type1_type,                        inverse_of: :extraction_forms_projects_sections_type1s, optional: true

  has_many :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy, inverse_of: :extraction_forms_projects_sections_type1
  has_many :timepoint_names, through: :extraction_forms_projects_sections_type1s_timepoint_names, dependent: :destroy

  validates :type1_id, uniqueness: { scope: :extraction_forms_projects_section_id }

  accepts_nested_attributes_for :type1, reject_if: :all_blank
  accepts_nested_attributes_for :timepoint_names, reject_if: :all_blank

  delegate :project, to: :extraction_forms_projects_section
  delegate :extraction_forms_project, to: :extraction_forms_projects_section

  def section_name
    extraction_forms_projects_section.section.name
  end

  def type1_attributes=(attributes)
    ExtractionFormsProjectsSectionsType1.transaction do
      attributes.delete(:id)  # Remove ID from hash since this may carry the ID of
                              # the object we are trying to change.
      self.type1 = Type1.find_or_create_by!(attributes)
      attributes[:id] = self.type1.id  # Need to put this back in, otherwise rails will
                                       # try to create this record, since its ID is
                                       # missing and it assumes it's a new item.
    end
    super
  end
end
