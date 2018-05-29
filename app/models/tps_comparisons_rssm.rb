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
end
