class Question < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  has_many :extraction_forms_projects_sections_questions, dependent: :destroy, inverse_of: :question
  has_many :extraction_forms_projects_sections, through: :extraction_forms_projects_sections_questions, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
