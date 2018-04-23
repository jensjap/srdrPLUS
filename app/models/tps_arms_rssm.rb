class TpsArmsRssm < ApplicationRecord
  include SharedParanoiaMethods

  belongs_to :extractions_extraction_forms_projects_sections_type1_row
  belongs_to :extractions_extraction_forms_projects_sections_type1
  belongs_to :result_statistic_sections_measure

  has_many :records, as: :recordable

  delegate :extraction, to: :extractions_extraction_forms_projects_sections_type1
  delegate :extractions_extraction_forms_projects_section, to: :extractions_extraction_forms_projects_sections_type1
end
