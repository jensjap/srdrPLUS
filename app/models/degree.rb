class Degree < ApplicationRecord
  has_many :degreeholderships, inverse_of: :degree
  has_many :profiles, through: :degreeholderships
end
