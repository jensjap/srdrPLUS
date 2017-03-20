class Title < ApplicationRecord
  has_many :profiles, dependent: :nullify
end
