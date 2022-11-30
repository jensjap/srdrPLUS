# == Schema Information
#
# Table name: tps_arms_rssms
#
#  id                                                      :integer          not null, primary key
#  timepoint_id                                            :integer
#  extractions_extraction_forms_projects_sections_type1_id :integer
#  result_statistic_sections_measure_id                    :integer
#  deleted_at                                              :datetime
#  active                                                  :boolean
#  created_at                                              :datetime         not null
#  updated_at                                              :datetime         not null
#

class TpsArmsRssm < ApplicationRecord
  belongs_to :extractions_extraction_forms_projects_sections_type1
  belongs_to :result_statistic_sections_measure
  belongs_to :timepoint,
             class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
             foreign_key: 'timepoint_id'

  has_many :records, as: :recordable

  delegate :extraction,                                    to: :extractions_extraction_forms_projects_sections_type1
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1
  delegate :result_statistic_section,                      to: :result_statistic_sections_measure

  def self.find_record_by_extraction(extraction, a, result_statistic_section, tp, rssm)
    _eefps_arm       = extraction.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section: a.extractions_extraction_forms_projects_section.extraction_forms_projects_section)
    _eefps_outcome   = extraction.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section: result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section)
    return nil if _eefps_arm.blank? or _eefps_outcome.blank?

    _eefpst1_arm     = _eefps_arm.extractions_extraction_forms_projects_sections_type1s.find_by(type1: a.type1)
    _eefpst1_outcome = _eefps_outcome.extractions_extraction_forms_projects_sections_type1s.find_by(type1: result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.type1)
    return nil if _eefpst1_arm.blank? or _eefpst1_outcome.blank?

    _eefpst1r = _eefpst1_outcome.extractions_extraction_forms_projects_sections_type1_rows.find_by(population_name: result_statistic_section.population.population_name)
    return nil if _eefpst1r.blank?

    _eefpst1rc       = _eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.find_by(timepoint_name: tp.timepoint_name)
    _rss             = _eefpst1r.result_statistic_sections.find_by(result_statistic_section_type: result_statistic_section.result_statistic_section_type)
    return nil if _rss.blank?

    _rssm            = _rss.result_statistic_sections_measures.find_by(measure: rssm.measure)
    _tps_arms_rssm   = TpsArmsRssm.find_by(timepoint: _eefpst1rc,
                                           extractions_extraction_forms_projects_sections_type1: _eefpst1_arm, result_statistic_sections_measure: _rssm)

    Record.find_by(recordable: _tps_arms_rssm)
  end

  def self.find_record(timepoint, extractions_extraction_forms_projects_sections_type1, result_statistic_sections_measure)
    tps_arms_rssm = find_or_create_by!(timepoint:,
                                       extractions_extraction_forms_projects_sections_type1:,
                                       result_statistic_sections_measure:)
    Record.find_or_create_by!(recordable: tps_arms_rssm)
  end
end
