class Type1Type < ApplicationRecord
  has_many :extractions_extraction_forms_projects_sections_type1s, inverse_of: :type1_type
  has_many :type1s, inverse_of: :type1_type
end
