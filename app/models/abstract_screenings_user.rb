class AbstractScreeningsUser < ApplicationRecord
  belongs_to :abstract_screening
  belongs_to :user

  delegate :handle, to: :user
end
