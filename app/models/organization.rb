class Organization < ApplicationRecord
  has_many :profiles, dependent: :nullify

  acts_as_paranoid
end
