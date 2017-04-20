class KeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  #!!! This should be before save or before_validation and properly find its position.
  after_initialize do |kqp|
    kqp.position = 1
  end

  belongs_to :key_question, inverse_of: :key_questions_projects
  belongs_to :project, inverse_of: :key_questions_projects

  validates :key_question_id, :project_id, presence: true
end
