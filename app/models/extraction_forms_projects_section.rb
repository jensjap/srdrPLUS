# == Schema Information
#
# Table name: extraction_forms_projects_sections
#
#  id                                        :integer          not null, primary key
#  extraction_forms_project_id               :integer
#  extraction_forms_projects_section_type_id :integer
#  section_id                                :integer
#  extraction_forms_projects_section_id      :integer
#  deleted_at                                :datetime
#  active                                    :boolean
#  created_at                                :datetime         not null
#  updated_at                                :datetime         not null
#  hidden                                    :boolean          default(FALSE)
#  helper_message                            :string(255)
#

class ExtractionFormsProjectsSection < ApplicationRecord
  include SharedOrderableMethods
  include SharedProcessTokenMethods
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    ExtractionFormsProjectsSectionOption.with_deleted.where(extraction_forms_projects_section_id: id).each(&:really_destroy!)
    Ordering.with_deleted.where(orderable_type: self.class, orderable_id: id).each(&:really_destroy!)
    ExtractionFormsProjectsSectionsType1
      .with_deleted
      .where(extraction_forms_projects_section_id: id)
      .each(&:really_destroy!)
    Question
      .with_deleted
      .where(extraction_forms_projects_section_id: id)
      .each(&:really_destroy!)

    extraction_forms_projects_section_type2s.with_deleted.each do |child|
      child.really_destroy!
    end
    extractions_extraction_forms_projects_sections.with_deleted.each do |child|
      child.really_destroy!
    end
    key_questions_projects.with_deleted.each do |child|
      child.really_destroy!
    end
  end

  scope :in_standard_extraction, lambda {
    joins(:extraction_forms_project)
      .where(extraction_forms_projects: { extraction_forms_project_type: ExtractionFormsProjectType.find_by_name(ExtractionFormsProjectType::STANDARD) })
  }
  scope :in_diagnostic_test_extraction, lambda {
    joins(:extraction_forms_project)
      .where(extraction_forms_projects: { extraction_forms_project_type: ExtractionFormsProjectType.find_by_name(ExtractionFormsProjectType::DIAGNOSTIC_TEST) })
  }
  scope :in_mini_extraction, lambda {
    joins(:extraction_forms_project)
      .where(extraction_forms_projects: { extraction_forms_project_type: ExtractionFormsProjectType.find_by_name(ExtractionFormsProjectType::MINI_EXTRACTION) })
  }
  ################################ CAUTION WHAT IS THIS FOR?
  # after_commit :mark_as_deleted_or_restore_extraction_forms_projects_section_option
  ################################
  after_create :create_extraction_forms_projects_section_option

  before_validation -> { set_ordering_scoped_by(:extraction_forms_project_id) }

  belongs_to :extraction_forms_project,                inverse_of: :extraction_forms_projects_sections
  belongs_to :extraction_forms_projects_section_type,  inverse_of: :extraction_forms_projects_sections
  belongs_to :link_to_type1, class_name: 'ExtractionFormsProjectsSection',
                             foreign_key: 'extraction_forms_projects_section_id',
                             optional: true
  belongs_to :section, inverse_of: :extraction_forms_projects_sections

  has_one :extraction_forms_projects_section_option, dependent: :destroy
  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :extraction_forms_projects_sections_type1s,
           -> { ordered },
           dependent: :destroy, inverse_of: :extraction_forms_projects_section
  # NOTE: This might be a bug...it's returning too many type1s.
  has_many :type1s,
           -> { joins(extraction_forms_projects_sections_type1s: :ordering) },
           through: :extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extraction_forms_projects_section_type2s, class_name: 'ExtractionFormsProjectsSection',
                                                      foreign_key: 'extraction_forms_projects_section_id'

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy,
                                                            inverse_of: :extraction_forms_projects_section
  has_many :extractions, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :key_questions_projects, dependent: :nullify, inverse_of: :extraction_forms_projects_section
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  has_many :questions,
           -> { ordered },
           dependent: :destroy, inverse_of: :extraction_forms_projects_section

  accepts_nested_attributes_for :extraction_forms_projects_sections_type1s, reject_if: :all_blank
  accepts_nested_attributes_for :extraction_forms_projects_section_option, reject_if: :all_blank
  # accepts_nested_attributes_for :type1s, reject_if: :all_blank

  delegate :project, to: :extraction_forms_project

  validates :ordering, presence: true

  validate :child_type
  validate :parent_type

  # !!! This code is repeated in model/ExtractionsExtractionFormsProjectsSection.
  #    We should move it somewhere to share.
  #
  # Do not create duplicate Type1 entries.
  #
  # In nested forms, the type1s_attributes hash will have IDs for entries that
  # are being modified (i.e. are tied to an existing record). We want to skip
  # over them. The ones that are lacking an ID entry are entries that are not
  # yet tied to an existing record. For these we check if they already exist
  # (by name and description) and then add to
  # extraction_forms_projects_section.type1s collection. Then call super to
  # update all the attributes of all submitted records.
  #
  # Note: This actually breaks validation. Presumably because validations happen
  #       later, after calling super. This is not a problem since there's
  #       nothing inherently wrong with creating an association between eefps and
  #       type1, where type1 has neither name or nor description.
  def type1s_attributes=(attributes)
    attributes.each do |key, attribute_collection|
      next if attribute_collection.has_key? 'id'

      Type1.transaction do
        type1 = Type1.find_or_create_by!(attribute_collection)
        type1s << type1 unless type1s.include? type1
        attributes[key]['id'] = type1.id.to_s
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
    section.name
  end

  # !!! this isn't working.
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

  def extraction_forms_projects_sections_type1s_without_total_arm
    extraction_forms_projects_sections_type1s
      .includes(:type1, :ordering, :type1_type, :extraction_forms_projects_sections_type1s_timepoint_names, :timepoint_names)
      .to_a
      .delete_if { |efpst| efpst.type1.name == 'Total' && efpst.type1.description == "All #{link_to_type1.present? ? link_to_type1.section.name : section.name} combined" }
  end

  def self.add_quality_dimension_by_questions_or_section(params)
    efps_id = params[0].to_i
    lsof_qdq_ids = params[1].split(',').map(&:to_i)

    return if lsof_qdq_ids.blank?

    # wrap in transaction
    ExtractionFormsProjectsSection.transaction do
      efps = ExtractionFormsProjectsSection.find(efps_id)

      # Iterate through the array of quality dimension question ids and add the question to the section.
      #
      depen_arr = []
      qrcqrco_id_dict = {}
      lsof_qdq_ids.each do |qdq_id|
        qdq = QualityDimensionQuestion.find(qdq_id)
        question = efps.questions.create(name: qdq.name, description: qdq.description)

        # Associate all key questions.
        question.key_questions_projects = question.project.key_questions_projects

        # if there are no options, then this quality dimension is a text question
        if qdq.quality_dimension_options
          qr_1 = question.question_rows.first
          qr_1.update(name: 'Rating')

          # Set field type (dropdown) for first for cell 1x1:
          qrc_1 = qr_1.question_row_columns.first
          qrc_1.update(question_row_column_type_id: 6)

          question.question_rows.create(name: 'Notes/Comments:')

          # Iterate through options and add them.
          first = true
          qdq.quality_dimension_options.each do |qdo|
            if first
              qrcqrco = qrc_1.question_row_columns_question_row_column_options.where(question_row_column_option_id: 1).first
              qrcqrco.update(name: qdo.name)

              first = false
            else
              qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create(
                question_row_column_id: qrc_1.id,
                question_row_column_option_id: 1,
                name: qdo.name
              )
            end
            qdqqdo = QualityDimensionQuestionsQualityDimensionOption.find_by quality_dimension_question: qdq,
                                                                             quality_dimension_option: qdo
            qrcqrco_id_dict[qdqqdo.id] = qrcqrco.id
          end # qdq.quality_dimension_options.each do |qdo|
        end
        qdq.dependencies.each do |prereq|
          depen_arr << [question.id, prereq.prerequisitable_id]
        end
      end # lsof_qdq_ids.each do |qdq_id|
      depen_arr.each do |q_id, prereq_id|
        Dependency.find_or_create_by! dependable_type: 'Question',
                                      dependable_id: q_id,
                                      prerequisitable_type: 'QuestionRowColumnsQuestionRowColumnOption',
                                      prerequisitable_id: qrcqrco_id_dict[prereq_id]
      end
    end  # ExtractionFormsProjectsSection.transaction do
  end

  def ensure_sequential_questions
    questions.each_with_index do |question, idx|
      question.position = idx + 1
    end
  end
end
