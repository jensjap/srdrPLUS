class Degree < ApplicationRecord
  include SharedMethods

  acts_as_paranoid
  has_paper_trail

  before_destroy :raise_error

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :degreeholderships, dependent: :destroy, inverse_of: :degree
  has_many :profiles, through: :degreeholderships

  private

  # You should NEVER delete a Degree.
  def raise_error
    raise 'You should NEVER delete a Degree.'
  end
end

