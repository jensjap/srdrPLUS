# == Schema Information
#
# Table name: comparable_elements
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  comparable_type :string(255)
#  comparable_id   :integer
#

class ComparableElement < ApplicationRecord
  attr_accessor :is_amoeba_copy

  amoeba do
    enable

    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  before_destroy :destroy_comparisons
  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :comparable, polymorphic: true

  has_many :comparates, dependent: :destroy, inverse_of: :comparable_element
  has_many :comparate_groups, through: :comparates
  has_many :comparisons, through: :comparate_groups

  private

  def destroy_comparisons
    comparisons.each(&:destroy)
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
