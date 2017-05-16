class ExtractionForm < ApplicationRecord
  include SharedPublishableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_many :extraction_forms_projects, inverse_of: :extraction_form, dependent: :destroy
  has_many :projects, through: :extraction_forms_projects, dependent: :destroy

  has_many :key_questions_projects, through: :extraction_forms_projects, dependent: :destroy
  has_many :key_questions, through: :extraction_forms_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
