# == Schema Information
#
# Table name: result_statistic_sections_measures
#
#  id                                   :integer          not null, primary key
#  measure_id                           :integer
#  result_statistic_section_id          :integer
#  deleted_at                           :datetime
#  active                               :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  result_statistic_sections_measure_id :integer
#

class ResultStatisticSectionsMeasure < ApplicationRecord
  include SharedOrderableMethods

  after_commit :set_extraction_stale, on: %i[create update destroy]

  before_validation -> { set_ordering_scoped_by(:result_statistic_section_id) }

  belongs_to :measure,                  inverse_of: :result_statistic_sections_measures
  belongs_to :result_statistic_section, inverse_of: :result_statistic_sections_measures
  belongs_to :provider_measure,
             class_name: 'ResultStatisticSectionsMeasure',
             foreign_key: 'result_statistic_sections_measure_id',
             optional: true

  has_many :dependent_measures,
           class_name: 'ResultStatisticSectionsMeasure',
           foreign_key: 'result_statistic_sections_measure_id'
  has_many :wacs_bacs_rssms, dependent: :destroy, inverse_of: :result_statistic_sections_measure
  has_many :tps_arms_rssms, dependent: :destroy, inverse_of: :result_statistic_sections_measure
  has_many :tps_comparisons_rssms, dependent: :destroy, inverse_of: :result_statistic_sections_measure
  has_many :comparisons_arms_rssms, dependent: :destroy, inverse_of: :result_statistic_sections_measure

  has_one :ordering, as: :orderable, dependent: :destroy

  accepts_nested_attributes_for :measure

  delegate :extraction, to: :result_statistic_section

  private

  def set_extraction_stale
    extraction.extraction_checksum.update(is_stale: true) unless extraction.nil?
  end
end
