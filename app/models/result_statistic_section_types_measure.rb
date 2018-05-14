class ResultStatisticSectionTypesMeasure < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :result_statistic_section_type, inverse_of: :result_statistic_section_types_measures
  belongs_to :measure,                       inverse_of: :result_statistic_section_types_measures
end
