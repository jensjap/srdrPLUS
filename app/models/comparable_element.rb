# == Schema Information
#
# Table name: comparable_elements
#
#  id              :integer          not null, primary key
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  comparable_type :string(255)
#  comparable_id   :integer
#  deleted_at      :datetime
#

class ComparableElement < ApplicationRecord
  before_destroy :destroy_comparisons

  belongs_to :comparable, polymorphic: true

  has_many :comparates, dependent: :destroy, inverse_of: :comparable_element
  has_many :comparate_groups, through: :comparates
  has_many :comparisons, through: :comparate_groups

  private

  def destroy_comparisons
    comparisons.each(&:destroy)
  end
end
