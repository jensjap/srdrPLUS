class ResultStatisticSectionType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :result_statistic_sections, dependent: :destroy, inverse_of: :result_statistic_section_type

  has_many :result_statistic_section_types_measures, dependent: :destroy, inverse_of: :result_statistic_section_type
  has_many :measures, through: :result_statistic_section_types_measures, dependent: :destroy
end
