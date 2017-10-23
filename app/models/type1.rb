class Type1 < ApplicationRecord
  belongs_to :extraction_forms_projects_section, inverse_of: :type1s

  delegate :project, to: :extraction_forms_projects_section
end
