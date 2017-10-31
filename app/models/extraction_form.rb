class ExtractionForm < ApplicationRecord
  include SharedPublishableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :extraction_form
  has_many :projects,               through: :extraction_forms_projects, dependent: :destroy
  has_many :key_questions_projects, through: :extraction_forms_projects, dependent: :destroy
  has_many :key_questions,          through: :extraction_forms_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: true }
end
