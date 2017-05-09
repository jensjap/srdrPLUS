class ExtractionForm < ApplicationRecord
  include SharedSuggestableMethods
  include SharedPublishableMethods

  acts_as_paranoid
  has_paper_trail

  belongs_to :extraction_form_type, inverse_of: :extraction_forms, optional: true

  has_many :extraction_forms_projects, inverse_of: :extraction_form, dependent: :destroy
  has_many :projects, through: :extraction_forms_projects, dependent: :destroy
  has_many :key_questions_projects, inverse_of: :extraction_form, dependent: :destroy
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
