class Type1 < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  default_scope { order(:id) }

  scope :uniq_by_section_name_and_not_included_in_efps, -> (efps_id) {
    efps = ExtractionFormsProjectsSection.find(efps_id)
    joins(extraction_forms_projects_sections_type1s: { extraction_forms_projects_section: :section })
      .where(sections: { name: efps.section.name })
      .where.not(extraction_forms_projects_sections_type1s: { type1: efps.type1s })
      .distinct
  }

  after_create :record_suggestor

  belongs_to :type1_type, inverse_of: :type1s, optional: true

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extraction_forms_projects_sections, through: :extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extractions_extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  delegate :project, to: :extraction_forms_projects_section

  validates :description, uniqueness: { scope: [:name, :type1_type_id] }

  def name_and_description
    text  = name
    text += " (#{ description })" if description.present?
    return text
  end

  def short_name_and_description
    if description.length < 10
      return name_and_description
    else
      text  = name
      text += " (#{ description.truncate(16, separator: /\s/) })" if description.present?
      return text
    end
  end

  def pretty_print_export_header
    short_name_and_description
  end
end
