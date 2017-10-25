class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_projects_section, inverse_of: :key_questions_projects, optional: true
  belongs_to :key_question, inverse_of: :key_questions_projects
  belongs_to :project, inverse_of: :key_questions_projects, touch: true

  has_many :extractions_key_questions_projects, dependent: :destroy, inverse_of: :key_questions_project
  has_many :extractions, through: :extractions_key_questions_projects, dependent: :destroy

  delegate :extraction_forms_project, to: :extraction_forms_projects_section
  delegate :extraction_form, to: :extraction_forms_project

  accepts_nested_attributes_for :key_question, reject_if: :key_question_name_exists?

  validate :extraction_forms_projects_section_is_key_question_type, if: :extraction_forms_projects_section_present?

  def extraction_forms_projects_section_present?
    self.extraction_forms_projects_section.present?
  end

  # Key Question should belong to ExtractionFormsProjectsSection that is of type 'Key Questions' only.
  def extraction_forms_projects_section_is_key_question_type
    unless self.extraction_forms_projects_section.extraction_forms_projects_section_type == ExtractionFormsProjectsSectionType.find_by(name: 'Key Questions')
      errors.add(:extraction_forms_projects_section_type, 'Is not of \'Key Questions\' type')
    end
  end

  def kq_name
    "#{ self.key_question.name }"
  end

  def kq_name_and_assignment
    "#{ self.key_question.name }" + (self.extraction_forms_projects_section.blank? ?
                                     ' (unassigned)' : " (assigned to: #{ self.extraction_form.name })")
  end

  private

    def key_question_name_exists?(attributes)
      return true if attributes[:name].blank?
      begin
        self.key_question = KeyQuestion.where(name: attributes[:name]).first_or_create!
      rescue ActiveRecord::RecordNotUnique
        retry
      end
    end
end
