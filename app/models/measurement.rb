class Measurement < ApplicationRecord
  belongs_to :comparisons_measure, required: false 
  has_one :measure, through: :comparisons_measure
end
