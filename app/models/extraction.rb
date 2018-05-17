class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  scope :by_user, -> ( user_id ) { joins(projects_users_role: { projects_user: :user })
    .where(projects_users: { user_id: user_id }) }

  belongs_to :project,             inverse_of: :extractions
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction
end
