class Comparate < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparate_group,    inverse_of: :comparates
  belongs_to :comparable_element, inverse_of: :comparates

  accepts_nested_attributes_for :comparable_element, allow_destroy: true
end
