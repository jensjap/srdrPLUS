class Degree < ApplicationRecord
  has_many :degreeholderships
  has_many :profiles, through: :degreeholderships, dependent: :destroy
end
