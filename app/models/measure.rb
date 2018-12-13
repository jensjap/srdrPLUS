class Measure < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  #scope :is_default, -> { where(default: true) }
  scope :result_statistic_section_type_defaults, -> ( result_statistic_section_type_id ) {
    joins(:result_statistic_section_types_measures)
      .where(result_statistic_section_types_measures: { result_statistic_section_type_id: result_statistic_section_type_id })
      .where(result_statistic_section_types_measures: { default: true })
  }

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :result_statistic_sections_measures, dependent: :destroy, inverse_of: :measure
  has_many :result_statistic_sections, through: :result_statistic_sections_measures, dependent: :destroy

  has_many :result_statistic_section_types_measures, dependent: :destroy, inverse_of: :measure
  has_many :result_statistic_section_types, through: :result_statistic_section_types_measures, dependent: :destroy

  has_many :comparisons_measures, dependent: :destroy
  has_many :comparisons, through: :comparisons_meausures
end
