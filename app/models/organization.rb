class Organization < ApplicationRecord
  acts_as_paranoid

  has_many :profiles, dependent: :destroy, inverse_of: :profile
end
