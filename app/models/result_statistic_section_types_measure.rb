# These are the measures that should appear for each result_statistic_section.
class ResultStatisticSectionTypesMeasure < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :result_statistic_section_type, inverse_of: :result_statistic_section_types_measures
  belongs_to :measure,                       inverse_of: :result_statistic_section_types_measures
  belongs_to :type1_type,                    inverse_of: :result_statistic_section_types_measures
  belongs_to :provider_measure,
    class_name: 'ResultStatisticSectionTypesMeasure',
    foreign_key: 'result_statistic_section_types_measure_id',
    optional: true

  has_many :dependent_measures,
    class_name: 'ResultStatisticSectionTypesMeasure',
    foreign_key: 'result_statistic_section_types_measure_id'
end
