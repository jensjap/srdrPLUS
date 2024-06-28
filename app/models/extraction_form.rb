# == Schema Information
#
# Table name: extraction_forms
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExtractionForm < ApplicationRecord
  include SharedPublishableMethods
  include SharedSuggestableMethods

  STANDARD = 'Standard'.freeze
  DIAGNOSTIC_TEST = 'Diagnostic Test'.freeze
  CITATION_SCREENING_EXTRACTION_FORM = 'Citation Screening Extraction Form'.freeze
  FULLTEXT_SCREENING_EXTRACTION_FORM = 'Fulltext Screening Extraction Form'.freeze

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :extraction_form
  has_many :projects, through: :extraction_forms_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: true }
end
