class ExtractionForm < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
