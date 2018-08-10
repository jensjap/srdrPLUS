class ComparateGroup < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :comparison, inverse_of: :comparate_groups

  has_many :comparates, inverse_of: :comparate_group, dependent: :destroy
  has_many :comparable_elements, through: :comparates, dependent: :destroy

  accepts_nested_attributes_for :comparates, reject_if: :all_blank, allow_destroy: true

  def eql?(other)
    self.comparates.map(&:comparable_element).map(&:comparable).to_set == other.comparates.map(&:comparable_element).map(&:comparable).to_set
  end
end
