class Comparison < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :result_statistic_section

  has_many :comparate_groups, dependent: :destroy
  has_many :comparates, through: :comparate_groups, dependent: :destroy
  has_many :comparable_elements, dependent: :destroy
end
