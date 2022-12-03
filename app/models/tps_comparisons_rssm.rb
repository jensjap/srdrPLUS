# == Schema Information
#
# Table name: tps_comparisons_rssms
#
#  id                                   :integer          not null, primary key
#  timepoint_id                         :integer
#  comparison_id                        :integer
#  result_statistic_sections_measure_id :integer
#  deleted_at                           :datetime
#  active                               :boolean
#  created_at                           :datetime         not null
#  updated_at                           :datetime         not null
#

class TpsComparisonsRssm < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  #before_destroy :really_destroy_children!
  def really_destroy_children!
    Record.with_deleted.where(recordable_type: self.class, recordable_id: id).each(&:really_destroy!)
  end

  belongs_to :comparison
  belongs_to :result_statistic_sections_measure
  belongs_to :timepoint,
             class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
             foreign_key: 'timepoint_id'

  has_many :records, as: :recordable

  # delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1_row

  def extraction
    ExtractionsExtractionFormsProjectsSectionsType1Row.with_deleted.find_by(id: extractions_extraction_forms_projects_sections_type1_row_id).try(:extraction)
  end

  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1_row
  delegate :result_statistic_section,                      to: :result_statistic_sections_measure

  def self.find_record_by_extraction
    'Mock Value'
  end

  def self.find_record(timepoint, comparison, result_statistic_sections_measure)
    tps_comparisons_rssm = find_or_create_by!(timepoint:,
                                              comparison:,
                                              result_statistic_sections_measure:)
    Record.find_or_create_by!(recordable: tps_comparisons_rssm)
  end
end
