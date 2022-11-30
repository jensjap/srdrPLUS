# == Schema Information
#
# Table name: comparate_groups
#
#  id            :integer          not null, primary key
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  comparison_id :integer
#  deleted_at    :datetime
#

class ComparateGroup < ApplicationRecord
  belongs_to :comparison, inverse_of: :comparate_groups

  has_many :comparates, inverse_of: :comparate_group, dependent: :destroy
  has_many :comparable_elements, through: :comparates, dependent: :destroy

  accepts_nested_attributes_for :comparates, reject_if: :all_blank, allow_destroy: true

  def eql?(other)
    if self.class != other.class
      false
    else
      comparates.map(&:comparable_element).map(&:comparable).to_set == other.comparates.map(&:comparable_element).map(&:comparable).to_set
    end
  end
end
