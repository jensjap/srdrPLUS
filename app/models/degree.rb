class Degree < ApplicationRecord
  include SharedSuggestableMethods
  include SharedQueryableMethods

  acts_as_paranoid
  has_paper_trail

  after_create :record_suggestor

  before_destroy :raise_error

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :degreeholderships, dependent: :destroy, inverse_of: :degree
  has_many :profiles, through: :degreeholderships, dependent: :destroy

  validates :name, uniqueness: true

  private

  # You should NEVER delete a Degree.
  def raise_error
    raise 'You should NEVER delete a Degree.'
  end
end

