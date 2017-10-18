class Extraction < ApplicationRecord
  belongs_to :projects_study, inverse_of: :extractions, optional: true
  belongs_to :projects_users_role, inverse_of: :extractions
  belongs_to :extraction_forms_project, inverse_of: :extractions
end
