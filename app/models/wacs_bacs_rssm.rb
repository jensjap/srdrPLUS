class WacsBacsRssm < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :wac, class_name: 'Comparison', foreign_key: 'wac_id', inverse_of: :wacs_bacs_rssms
  belongs_to :bac, class_name: 'Comparison', foreign_key: 'bac_id', inverse_of: :wacs_bacs_rssms
  belongs_to :result_statistic_sections_measure,                    inverse_of: :wacs_bacs_rssms

  has_many :records, as: :recordable

  delegate :result_statistic_section, to: :result_statistic_sections_measure

  def self.find_record_by_extraction()

    return 'Mock Value'
  end
end
