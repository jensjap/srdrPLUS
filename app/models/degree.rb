class Degree < ApplicationRecord
  acts_as_paranoid

  has_many :degreeholderships, inverse_of: :degree
  has_many :profiles, through: :degreeholderships, dependent: :destroy
end
