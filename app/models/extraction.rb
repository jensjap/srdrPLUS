class Extraction < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  after_create :prepare_extraction

  belongs_to :project,             inverse_of: :extractions
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

  private

    def prepare_extraction
      # It is possible to have more than one, but at the moment the decision was made to restrict to one extraction form.
      efp = project.extraction_forms_projects.first
      byebug
      efp.extraction_forms_projects_sections.each do |efps|

      end
    end
end
