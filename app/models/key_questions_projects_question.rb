class KeyQuestionsProjectsQuestion < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :key_questions_project, inverse_of: :key_questions_projects_questions
  belongs_to :question,              inverse_of: :key_questions_projects_questions
end
