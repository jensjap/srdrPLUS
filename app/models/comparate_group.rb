class ComparateGroup < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparison, inverse_of: :comparate_groups

  has_many :comparates, dependent: :destroy, inverse_of: :comparate_group
  has_many :comparable_elements, through: :comparates, dependent: :destroy

  accepts_nested_attributes_for :comparates, reject_if: :all_blank, allow_destroy: true
end
