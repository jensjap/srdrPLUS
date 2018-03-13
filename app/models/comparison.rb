class Comparison < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :result_statistic_section

  has_one :result_statistic_sections_measures_comparison, dependent: :destroy

  has_many :comparate_groups, dependent: :destroy
  has_many :comparates, through: :comparate_groups, dependent: :destroy

  accepts_nested_attributes_for :comparate_groups, allow_destroy: true
end
