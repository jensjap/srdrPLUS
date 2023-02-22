# == Schema Information
#
# Table name: key_questions_projects
#
#  id                                   :integer          not null, primary key
#  extraction_forms_projects_section_id :integer
#  key_question_id                      :integer
#  project_id                           :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  pos                                  :integer          default(999999)
#

class KeyQuestionsProject < ApplicationRecord
  default_scope { order(:pos, :id) }

  belongs_to :extraction_forms_projects_section, inverse_of: :key_questions_projects, optional: true
  belongs_to :key_question,                      inverse_of: :key_questions_projects
  belongs_to :project,                           inverse_of: :key_questions_projects # , touch: true

  has_many :key_questions_projects_questions, dependent: :destroy, inverse_of: :key_questions_project
  has_many :questions, through: :key_questions_projects_questions

  has_many :sd_key_questions_projects, inverse_of: :key_questions_project
  has_many :sd_key_questions, through: :sd_key_questions_projects

  has_many :extractions_key_questions_projects_selections, dependent: :destroy

  delegate :extraction_forms_project, to: :extraction_forms_projects_section
  delegate :extraction_form, to: :extraction_forms_project

  accepts_nested_attributes_for :key_question, reject_if: :key_question_name_exists?

  validate :extraction_forms_projects_section_is_key_question_type, if: :extraction_forms_projects_section_present?

  def extraction_forms_projects_section_present?
    extraction_forms_projects_section.present?
  end

  # Key Question should belong to ExtractionFormsProjectsSection that is of type 'Key Questions' only.
  def extraction_forms_projects_section_is_key_question_type
    unless extraction_forms_projects_section.extraction_forms_projects_section_type == ExtractionFormsProjectsSectionType.find_by(name: 'Key Questions')
      errors.add(:extraction_forms_projects_section_type, 'Is not of \'Key Questions\' type')
    end
  end

  def kq_name
    "#{key_question.name}"
  end

  def kq_name_and_assignment
    "#{key_question.name}" + (if extraction_forms_projects_section.blank?
                                ' (unassigned)'
                              else
                                " (assigned to: #{extraction_form.name})"
                              end)
  end

  def kq_name_and_unassigned
    if extraction_forms_projects_section.blank?
      "#{key_question.name} (not assigned to any extraction form)"
    else
      key_question.name
    end
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
