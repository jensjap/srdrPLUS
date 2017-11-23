class Type1 < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

#  scope :by_section_name_and_extraction_id_and_extraction_forms_project_id, -> (section_name, extraction_id, extraction_forms_project_id) {
#    joins(extractions_extraction_forms_projects_sections_type1s: { extractions_extraction_forms_projects_section: [:extraction, { extraction_forms_projects_section: [:extraction_forms_project, :section] }] })
#      .where(sections: { name: section_name })
#      .where(extractions: { id: extraction_id })
#      .where(extraction_forms_projects: { id: extraction_forms_project_id })
#  }

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  #belongs_to :extraction_forms_projects_section, inverse_of: :type1s
  has_many :extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extraction_forms_projects_sections, through: :extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extractions_extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  delegate :project, to: :extraction_forms_projects_section

  validates :description, uniqueness: { scope: :name }

  def name_and_description
    text = name
    text.concat " (#{ description })" if description.present?
    return text
  end
end
