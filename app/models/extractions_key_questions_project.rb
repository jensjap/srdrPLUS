class ExtractionsKeyQuestionsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction,            inverse_of: :extractions_key_questions_projects
  belongs_to :key_questions_project, inverse_of: :extractions_key_questions_projects
end
