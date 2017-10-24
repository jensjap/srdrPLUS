class Type1 < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  belongs_to :extraction_forms_projects_section, inverse_of: :type1s

  delegate :project, to: :extraction_forms_projects_section
end
