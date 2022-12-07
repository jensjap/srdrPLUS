# == Schema Information
#
# Table name: measures
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Measure < ApplicationRecord
  include SharedSuggestableMethods

  # scope :is_default, -> { where(default: true) }
  scope :result_statistic_section_type_defaults, lambda { |result_statistic_section_type_id|
    joins(:result_statistic_section_types_measures)
      .where(result_statistic_section_types_measures: { result_statistic_section_type_id: })
      .where(result_statistic_section_types_measures: { default: true })
  }

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :result_statistic_sections_measures, dependent: :destroy, inverse_of: :measure
  has_many :result_statistic_sections, through: :result_statistic_sections_measures, dependent: :destroy

  has_many :result_statistic_section_types_measures, dependent: :destroy, inverse_of: :measure
  has_many :result_statistic_section_types, through: :result_statistic_section_types_measures, dependent: :destroy

  has_many :comparisons_measures, dependent: :destroy
  has_many :comparisons, through: :comparisons_measures
end
