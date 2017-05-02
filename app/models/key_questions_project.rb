class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  before_create do |key_questions_project|
    key_questions_project.assign_attributes(
      { position: KeyQuestionsProject.where(project: project).count + 1 }
    )
  end

  belongs_to :key_question, inverse_of: :key_questions_projects, optional: true
  belongs_to :project, inverse_of: :key_questions_projects

  accepts_nested_attributes_for :key_question, reject_if: :key_question_name_exists

  validates_uniqueness_of :key_question, scope: :project

  private

  def key_question_name_exists(key_question_attributes)
    if _key_question = KeyQuestion.where(name: key_question_attributes[:name]).first_or_create
      # Associate this KeyQuestionsProject with the existing KeyQuestion.
      self.key_question = _key_question
      return true
    end

    return false
  end
end
