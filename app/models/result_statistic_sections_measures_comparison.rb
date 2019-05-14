# == Schema Information
#
# Table name: result_statistic_sections_measures_comparisons
#
#  id                          :integer          not null, primary key
#  result_statistic_section_id :integer
#  comparison_id               :integer
#  created_at                  :datetime         not null
#  updated_at                  :datetime         not null
#

class ResultStatisticSectionsMeasuresComparison < ApplicationRecord
  belongs_to :result_statistic_section
  belongs_to :comparison
end
