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
end
