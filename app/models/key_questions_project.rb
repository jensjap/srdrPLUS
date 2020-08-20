# == Schema Information
#
# Table name: key_questions_projects
#
#  id                                   :integer          not null, primary key
#  extraction_forms_projects_section_id :integer
#  key_question_id                      :integer
#  project_id                           :integer
#  deleted_at                           :datetime
#  active                               :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods
  include SharedOrderableMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  before_validation -> { set_ordering_scoped_by(:extraction_forms_projects_section_id) }, on: :create

  belongs_to :extraction_forms_projects_section, inverse_of: :key_questions_projects, optional: true
  belongs_to :key_question,                      inverse_of: :key_questions_projects
  belongs_to :project,                           inverse_of: :key_questions_projects, touch: true

  has_one :ordering, as: :orderable, dependent: :destroy

  has_many :key_questions_projects_questions, dependent: :destroy, inverse_of: :key_questions_project
  has_many :questions, through: :key_questions_projects_questions, dependent: :destroy

  has_many :sd_key_questions_projects, inverse_of: :key_questions_project
  has_many :sd_key_questions, through: :sd_key_questions_projects

  has_many :extractions_key_questions_projects_selections, dependent: :destroy

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

  def kq_name_and_unassigned
    if self.extraction_forms_projects_section.blank?
      "#{ self.key_question.name } (not assigned to any extraction form)"
    else
      self.key_question.name
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
