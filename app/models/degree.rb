class Degree < ApplicationRecord
  has_paper_trail

  before_destroy :raise_error

  has_many :degreeholderships, inverse_of: :degree
  has_many :profiles, through: :degreeholderships

  private

  # You should NEVER delete a Degree.
  def raise_error
    raise 'You should NEVER delete a Degree.'
  end
end

