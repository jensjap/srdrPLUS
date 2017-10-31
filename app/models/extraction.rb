class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :projects_study, inverse_of: :extractions, optional: true
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy
  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction
  has_many :extractions_key_questions_projects, dependent: :destroy, inverse_of: :extraction
  has_many :key_questions_projects, through: :extractions_key_questions_projects, dependent: :destroy

  validates :key_questions_projects, presence: true

  delegate :project, to: :projects_users_role
end
