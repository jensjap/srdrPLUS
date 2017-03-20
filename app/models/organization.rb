class Organization < ApplicationRecord
  has_many :profiles, dependent: :nullify
end
