class Comparison < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :result_statistic_section

  has_many :comparate_groups, dependent: :destroy
  has_many :comparates, through: :comparate_groups, dependent: :destroy
  has_many :comparisons_measures, dependent: :destroy
  has_many :measurements, through: :comparisons_measures, dependent: :destroy
  has_many :measures, through: :comparisons_measures

  accepts_nested_attributes_for :comparate_groups, allow_destroy: true
  accepts_nested_attributes_for :comparisons_measures, allow_destroy: true
  accepts_nested_attributes_for :measurements, allow_destroy: true
end
