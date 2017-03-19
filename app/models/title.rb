class Title < ApplicationRecord
  has_many :user_details, dependent: :nullify
end
