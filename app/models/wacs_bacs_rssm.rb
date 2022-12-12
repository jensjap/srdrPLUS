# == Schema Information
#
# Table name: wacs_bacs_rssms
#
#  id                                   :integer          not null, primary key
#  wac_id                               :integer
#  bac_id                               :integer
#  result_statistic_sections_measure_id :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class WacsBacsRssm < ApplicationRecord
  belongs_to :wac, class_name: 'Comparison', foreign_key: 'wac_id', inverse_of: :wacs_bacs_rssms
  belongs_to :bac, class_name: 'Comparison', foreign_key: 'bac_id', inverse_of: :wacs_bacs_rssms
  belongs_to :result_statistic_sections_measure,                    inverse_of: :wacs_bacs_rssms

  has_many :records, as: :recordable

  delegate :result_statistic_section, to: :result_statistic_sections_measure

  def self.find_record_by_extraction
    'Mock Value'
  end

  def self.find_record(wac, bac, result_statistic_sections_measure)
    wac_bac_rssm = WacsBacsRssm.find_or_create_by!(wac:,
                                                   bac:,
                                                   result_statistic_sections_measure:)
    Record.find_or_create_by!(recordable: wac_bac_rssm)
  end
end
