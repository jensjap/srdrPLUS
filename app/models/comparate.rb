class Comparate < ApplicationRecord
  belongs_to :comparate_group
  belongs_to :comparable_element, dependent: :destroy
end
