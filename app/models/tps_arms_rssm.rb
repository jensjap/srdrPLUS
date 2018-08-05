class TpsArmsRssm < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extractions_extraction_forms_projects_sections_type1
  belongs_to :result_statistic_sections_measure
  belongs_to :timepoint,
    class_name: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn',
    foreign_key: 'timepoint_id'

  has_many :records, as: :recordable

  delegate :extraction,                                    to: :extractions_extraction_forms_projects_sections_type1_row
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1_row
  delegate :result_statistic_section,                      to: :result_statistic_sections_measure

  def self.find_record_by_extraction(extraction, a, result_statistic_section, tp, rssm)
    _eefps_arm       = ExtractionsExtractionFormsProjectsSection.find_by!(extraction: extraction, extraction_forms_projects_section: a.extractions_extraction_forms_projects_section.extraction_forms_projects_section)
    _eefps_outcome   = ExtractionsExtractionFormsProjectsSection.find_by!(extraction: extraction, extraction_forms_projects_section: result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section)
    _eefpst1_arm     = ExtractionsExtractionFormsProjectsSectionsType1.find_by!(extractions_extraction_forms_projects_section: _eefps_arm, type1: a.type1)
    _eefpst1_outcome = ExtractionsExtractionFormsProjectsSectionsType1.find_by!(extractions_extraction_forms_projects_section: _eefps_outcome, type1: result_statistic_section.population.extractions_extraction_forms_projects_sections_type1.type1)
    _eefpst1r        = ExtractionsExtractionFormsProjectsSectionsType1Row.find_by!(extractions_extraction_forms_projects_sections_type1: _eefpst1_outcome, population_name: result_statistic_section.population.population_name)
    _eefpst1rc       = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_by!(extractions_extraction_forms_projects_sections_type1_row: _eefpst1r, timepoint_name: tp.timepoint_name)
    _rss             = ResultStatisticSection.find_by!(result_statistic_section_type: result_statistic_section.result_statistic_section_type, population: _eefpst1r)
    _rssm            = ResultStatisticSectionsMeasure.find_by!(result_statistic_section: _rss, measure: rssm.measure)
    _tps_arms_rssm   = TpsArmsRssm.find_by!(timepoint: _eefpst1rc, extractions_extraction_forms_projects_sections_type1: _eefpst1_arm, result_statistic_sections_measure: _rssm)

    return Record.find_by!(recordable: _tps_arms_rssm)
  end
end
