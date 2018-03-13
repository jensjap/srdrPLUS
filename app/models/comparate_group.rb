class ComparateGroup < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparison, required: false

  has_many :comparates, dependent: :destroy
  has_many :comparable_elements, through: :comparates, dependent: :destroy

  accepts_nested_attributes_for :comparates, allow_destroy: true
end
