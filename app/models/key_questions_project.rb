class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  before_create do |key_questions_project|
    key_questions_projects = KeyQuestionsProject.where(project: project)
    key_questions_project.position = key_questions_projects.blank? ?
        1 : key_questions_projects.order(position: :desc).first.position + 1
  end

  belongs_to :key_question, inverse_of: :key_questions_projects
  belongs_to :project, inverse_of: :key_questions_projects

  accepts_nested_attributes_for :key_question, reject_if: :all_blank
  #accepts_nested_attributes_for :key_question, reject_if: :check_key_question

  private

  def check_key_question(key_question_attributes)
    if _key_question = KeyQuestion.find_by(name: key_question_attributes[:name])
      self.key_question = _key_question
      return true
    else
      return false
    end
  end
end
