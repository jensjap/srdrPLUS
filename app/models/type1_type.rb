class Type1Type < ApplicationRecord
  has_many :extraction_forms_projects_sections_type1s,             inverse_of: :type1_type
  has_many :extractions_extraction_forms_projects_sections_type1s, inverse_of: :type1_type
  has_many :result_statistic_sections_measures,                    inverse_of: :type1_type
  has_many :result_statistic_section_types_measures,               inverse_of: :type1_type
end
