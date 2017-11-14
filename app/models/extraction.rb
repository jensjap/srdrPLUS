class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :projects_study,      inverse_of: :extractions, optional: true
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

  has_many :extractions_key_questions_projects, dependent: :destroy, inverse_of: :extraction
  has_many :key_questions_projects, through: :extractions_key_questions_projects, dependent: :destroy

  validates :key_questions_projects, presence: true

  delegate :project, to: :projects_users_role

  def extraction_forms_projects
    #!!! Make this a proper query.
    @extraction_forms_projects = Set.new
    self.extractions_key_questions_projects
      .includes(key_questions_project: [extraction_forms_projects_section: [:extraction_forms_projects_section_type, :section, extraction_forms_project: [:extraction_form]]])
      .order(key_questions_project_id: :asc)
      .each do |ekqp|
      if ekqp.key_questions_project.extraction_forms_projects_section
        @extraction_forms_projects << ekqp.key_questions_project.extraction_forms_projects_section.extraction_forms_project
      end
    end
    return @extraction_forms_projects
  end
end
