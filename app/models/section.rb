class Section < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects_sections, dependent: :destroy, inverse_of: :section

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
