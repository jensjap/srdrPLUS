class Question < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :extraction_forms_projects_section, inverse_of: :questions
  belongs_to :question_type, inverse_of: :questions

  validates :name, presence: true
end
