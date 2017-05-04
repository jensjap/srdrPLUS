class ExtractionForm < ApplicationRecord
  include SharedSuggestableMethods
  include SharedPublishableMethods

  acts_as_paranoid
  has_paper_trail

  has_many :key_questions, inverse_of: :extraction_form

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
