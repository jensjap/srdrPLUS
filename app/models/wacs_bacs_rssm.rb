class WacsBacsRssm < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :wac, class_name: 'Comparison', foreign_key: 'wac_id'
  belongs_to :bac, class_name: 'Comparison', foreign_key: 'bac_id'
  belongs_to :result_statistic_sections_measure

  has_many :records, as: :recordable

  delegate :result_statistic_section, to: :result_statistic_sections_measure
end
