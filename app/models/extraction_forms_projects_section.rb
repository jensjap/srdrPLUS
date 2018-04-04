class ExtractionFormsProjectsSection < ApplicationRecord
  include SharedOrderableMethods
  include SharedProcessTokenMethods
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  default_scope { order(id: :asc) }

  after_save :mark_as_deleted_or_restore_extraction_forms_projects_section_option

  before_validation -> { set_ordering_scoped_by(:extraction_forms_project_id) }

  belongs_to :extraction_forms_project,                inverse_of: :extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section_type,  inverse_of: :extraction_forms_projects_sections
  belongs_to :link_to_type1, class_name: 'ExtractionFormsProjectsSection',
    foreign_key: 'extraction_forms_projects_section_id',
    optional: true
  belongs_to :section, inverse_of: :extraction_forms_projects_sections

  delegate :project, to: :extraction_forms_project

  has_one :extraction_forms_projects_section_option, dependent: :destroy
  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :extraction_forms_projects_section
  has_many :type1s, through: :extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extraction_forms_projects_section_type2s, class_name:  'ExtractionFormsProjectsSection',
                                                      foreign_key: 'extraction_forms_projects_section_id'

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction_forms_projects_section
  has_many :extractions, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :key_questions_projects, dependent: :nullify, inverse_of: :extraction_forms_projects_section
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  has_many :questions, dependent: :destroy, inverse_of: :extraction_forms_projects_section

  accepts_nested_attributes_for :type1s, reject_if: :all_blank

  validates :ordering, presence: true

  validate :child_type
  validate :parent_type

  def key_questions_projects_array
    key_questions_projects = Array.new
    self.questions.each do |q|
      key_questions_projects = key_questions_projects | q.key_questions_projects
    end

    return key_questions_projects.map { |kqp| [kqp.key_question.name, kqp.id] }
  end

  # Do not create duplicate Type1 entries.
  #
  # In nested forms the type1s_attributes hash will have IDs for entries that
  # are being modified (i.e. are tied to an existing record). We want to skip
  # over them. The ones that are lacking an ID entry are entries that are not
  # yet tied to an existing record. For these we check if they already exist
  # (by name and description) and then add to
  # extraction_forms_projects_section.type1s collection. Then call super to
  # update all the attributes of all submitted records.
  def type1s_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      unless attribute_collection.has_key? 'id'
        Type1.transaction do
          type1 = Type1.find_or_create_by!(attribute_collection)
          type1s << type1 unless type1s.include? type1
          attributes[key]['id'] = type1.id.to_s
        end
      end
    end
    super
  end

  def section_id=(token)
    resource = Section.new
    save_resource_name_with_token(resource, token)
    super
  end

  def section_label
    self.section.name
  end

  #!!! this isn't working.
  def child_type
#    errors[:base] << 'Child Type must be of Type 2' unless self.link_to_type1.present? &&
#      self.extraction_forms_projects_section_type_id != 2
  end

  def parent_type
    errors[:base] << 'Parent Type must be of Type 1' unless link_to_type1.nil? ||
      link_to_type1.extraction_forms_projects_section_type_id == 1
  end

  def mark_as_deleted_or_restore_extraction_forms_projects_section_option
    if extraction_forms_projects_section_type_id == 2
      option = ExtractionFormsProjectsSectionOption.with_deleted.find_or_create_by(extraction_forms_projects_section: self)
      option.restore if option.deleted?
    else
      option = ExtractionFormsProjectsSectionOption.find_by(extraction_forms_projects_section: self)
      option.destroy if option
    end
  end

  def self.add_quality_dimension_by_questions_or_section(params)
    efps_id = params[0].to_i
    lsof_qdq_ids = params[1].split(',').map(&:to_i)

    return if lsof_qdq_ids.blank?

    #wrap in transaction
    ExtractionFormsProjectsSection.transaction do

      efps = ExtractionFormsProjectsSection.find(efps_id)

      # Iterate through the array of quality dimension question ids and add the question to the section.
      lsof_qdq_ids.each do |qdq_id|
        qdq = QualityDimensionQuestion.find(qdq_id)
        q = efps.questions.create(name: qdq.name, description: qdq.description)

        # Associate all key questions.
        p = q.project
        p.key_questions_projects.each do |kqp|
          q.key_questions_projects << kqp
        end

        # Set field type.
        qrcf = q.question_rows.first.question_row_columns.first.question_row_column_field
        qrcf.update(question_row_column_field_type: QuestionRowColumnFieldType.find_by(name: 'dropdown'))

        # Iterate through options and add them.
        first = true
        qdq.quality_dimension_options.each do |qdo|
          if first
            qrcfqrcfo = qrcf.question_row_column_fields_question_row_column_field_options.where(question_row_column_field_option_id: 1).first
            qrcfqrcfo.update(name: qdo.name)
            first = false
          else
            qrcf.question_row_column_fields_question_row_column_field_options.create(
              question_row_column_field_option: QuestionRowColumnFieldOption.find_by(name: 'answer_choice'),
              name: qdo.name,
              name_type: 'string'
            )
          end
        end  # qdq.quality_dimension_options.each do |qdo|
      end  # lsof_qdq_ids.each do |qdq_id|
    end  # ExtractionFormsProjectsSection.transaction do
  end
end
