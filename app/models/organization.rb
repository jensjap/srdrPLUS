class Organization < ApplicationRecord
  acts_as_paranoid

  has_many :profiles, dependent: :nullify, inverse_of: :profile
end

