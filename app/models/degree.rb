class Degree < ApplicationRecord
  include SharedMethods

  after_create :record_suggestor

  acts_as_paranoid
  has_paper_trail

  before_destroy :raise_error

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :degreeholderships, dependent: :destroy, inverse_of: :degree
  has_many :profiles, through: :degreeholderships

  private

  def record_suggestor
    self.create_suggestion(user: User.current) if User.current
  end

  # You should NEVER delete a Degree.
  def raise_error
    raise 'You should NEVER delete a Degree.'
  end
end

