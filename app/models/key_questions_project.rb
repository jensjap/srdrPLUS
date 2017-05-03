class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :key_question, inverse_of: :key_questions_projects, optional: true
  belongs_to :project, inverse_of: :key_questions_projects

  accepts_nested_attributes_for :key_question, reject_if: :key_question_name_exists?

  #!!! Can't get the error to show on key_questions_project.
  #validates_uniqueness_of :key_question, scope: :project, conditions: -> { where( active: true ) }

  private

  def key_question_name_exists?(key_question_attributes)
    if _key_question = KeyQuestion.where(name: key_question_attributes[:name]).first
      # Associate this KeyQuestionsProject with the existing KeyQuestion.
      self.key_question = _key_question
      return true
    end

    return false
  end
end
