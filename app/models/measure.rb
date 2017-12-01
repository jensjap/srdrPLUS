class Measure < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  scope :is_default, -> { where(default: true) }

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :result_statistic_sections_measures, dependent: :destroy, inverse_of: :measure
  has_many :result_statistic_sections, through: :result_statistic_sections_measures, dependent: :destroy
end
