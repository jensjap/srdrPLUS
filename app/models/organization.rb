class Organization < ApplicationRecord
  include SharedSuggestableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :profiles, dependent: :nullify, inverse_of: :profile

  validates :name, uniqueness: true
end

