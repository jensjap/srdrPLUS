class Project < ApplicationRecord
  include SharedMethods

  acts_as_paranoid
  has_paper_trail

  paginates_per 8

  has_many :publishings, as: :publishable, dependent: :destroy

  # Requesting publishing will create a Publishing record which
  # carries the information of who submitted the request.
  def request_publishing
    publishings.create(requested_by: User.current)
  end
end
