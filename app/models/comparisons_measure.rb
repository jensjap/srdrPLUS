# == Schema Information
#
# Table name: comparisons_measures
#
#  id            :integer          not null, primary key
#  measure_id    :integer
#  comparison_id :integer
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

class ComparisonsMeasure < ApplicationRecord
  belongs_to :comparison
  belongs_to :measure, required: false

#    has_one :measurement, dependent: :destroy

#    accepts_nested_attributes_for :measurement, allow_destroy: true
end
