# == Schema Information
#
# Table name: result_statistic_sections_measures
#
#  id                                   :integer          not null, primary key
#  measure_id                           :integer
#  result_statistic_section_id          :integer
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#  result_statistic_sections_measure_id :integer
#  pos                                  :integer          default(999999)
#

class ResultStatisticSectionsMeasure < ApplicationRecord
  attr_accessor :is_amoeba_copy

  default_scope { order(:pos, :id) }

  amoeba do
    exclude_association :dependent_measures

    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  after_commit :set_extraction_stale, on: %i[create update destroy]

  before_commit :correct_parent_associations

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

  accepts_nested_attributes_for :measure

  delegate :extraction,                                    to: :result_statistic_section
  delegate :extractions_extraction_forms_projects_section, to: :result_statistic_section
  delegate :project, to: :extraction

  private

  def set_extraction_stale
    extraction.extraction_checksum&.update(is_stale: true) unless extraction.nil?
  end

  def correct_parent_associations
    return unless is_amoeba_copy

    correct_provider_measure
  end

  def correct_provider_measure
    return unless self.provider_measure.present?

    rssms = ResultStatisticSectionsMeasure.where(
      result_statistic_section:,
      measure: self.provider_measure.measure
    )
    raise unless rssms.size.eql?(1)

    self.update(provider_measure: rssms[0])
  end
end
