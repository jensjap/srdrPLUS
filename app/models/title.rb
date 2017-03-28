class Title < ApplicationRecord
  has_many :titleships
  has_many :profiles, through: :titleships, dependent: :destroy
end
