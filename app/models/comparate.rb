class Comparate < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparate_group
  belongs_to :comparable_element

  accepts_nested_attributes_for :comparable_element,
    allow_destroy: true
end
