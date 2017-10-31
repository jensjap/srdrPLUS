class ExtractionFormsProjectsSection < ApplicationRecord
  include SharedOrderableMethods
  include SharedProcessTokenMethods
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  after_create :mark_as_deleted_or_restore_extraction_forms_projects_section_option

  before_validation -> { set_ordering_scoped_by(:extraction_forms_project_id) }

  belongs_to :extraction_forms_project,                inverse_of: :extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section_type,  inverse_of: :extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section_type1, class_name: 'ExtractionFormsProjectsSection',
    foreign_key: 'extraction_forms_projects_section_id',
    optional: true
  belongs_to :section, inverse_of: :extraction_forms_projects_sections

  delegate :project, to: :extraction_forms_project

  has_one :extraction_forms_projects_section_option, dependent: :destroy
  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction_forms_projects_section
  has_many :extractions, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extraction_forms_projects_section_type2s, class_name:  'ExtractionFormsProjectsSection',
                                                      foreign_key: 'extraction_forms_projects_section_id'

  has_many :key_questions_projects, dependent: :nullify, inverse_of: :extraction_forms_projects_section
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  has_many :questions, dependent: :destroy, inverse_of: :extraction_forms_projects_section

  has_many :type1s, dependent: :destroy, inverse_of: :extraction_forms_projects_section

  validates :ordering, presence: true

  validate :child_type
  validate :parent_type

  def section_id=(token)
    process_token(token, :section)
    super
  end

  def section_label
    self.section.name
  end

  #!!! this isn't working.
  def child_type
#    errors[:base] << 'Child Type must be of Type 2' unless self.extraction_forms_projects_section_type1.present? &&
#      self.extraction_forms_projects_section_type_id != 2
  end

  def parent_type
    errors[:base] << 'Parent Type must be of Type 1' unless extraction_forms_projects_section_type1.nil? ||
      extraction_forms_projects_section_type1.extraction_forms_projects_section_type_id == 1
  end

  def mark_as_deleted_or_restore_extraction_forms_projects_section_option
    option = ExtractionFormsProjectsSectionOption.with_deleted.find_or_create_by(extraction_forms_projects_section: self)
    if extraction_forms_projects_section_type_id == 2
      option.restore
    else
      option.delete
    end
  end
end
