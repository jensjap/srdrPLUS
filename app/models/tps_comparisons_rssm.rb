class TpsComparisonsRssm < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :comparison
  belongs_to :result_statistic_sections_measure
  belongs_to :timepoint,
    class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
    foreign_key: 'timepoint_id'

  has_many :records, as: :recordable

  delegate :extraction,                                    to: :extractions_extraction_forms_projects_sections_type1_row
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1_row
  delegate :result_statistic_section,                      to: :result_statistic_sections_measure

  def self.find_record_by_extraction()

    return 'Mock Value'
  end

  def self.find_record(timepoint, comparison, result_statistic_sections_measure)
    tps_comparisons_rssm = self.find_or_create_by!(timepoint: timepoint,
                                                  comparison: comparison,
                                                  result_statistic_sections_measure: result_statistic_sections_measure)
    return Record.find_or_create_by!(recordable: tps_comparisons_rssm)
  end
end
