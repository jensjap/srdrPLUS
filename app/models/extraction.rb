class Extraction < ApplicationRecord
  include ConsolidationHelper

  acts_as_paranoid
  has_paper_trail

  #!!! We can't implement this without ensuring integrity of the extraction form. It is possible that the database
  #    is rendered inconsistent if a project lead changes links between type1 and type2 after this hook is called.
  #    We need something that ensures consistency when linking is changed.
  #
  # Note: 6/25/2018 - We call ensure_extraction_form_structure in work and consolidate action. this might be enough
  #                   to ensure consistency?
  after_create :ensure_extraction_form_structure

  scope :by_project_and_user, -> ( project_id, user_id ) {
    joins(projects_users_role: { projects_user: :user })
    .where(project_id: project_id)
    .where(projects_users: { user_id: user_id })
  }

  scope :consolidated,   -> () { where(consolidated: true) }
  scope :unconsolidated, -> () { where(consolidated: false) }

  belongs_to :project,             inverse_of: :extractions
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

  delegate :citation, to: :citations_project
  delegate :user, to: :projects_users_role

#  def to_builder
#    Jbuilder.new do |extraction|
#      extraction.sections extractions_extraction_forms_projects_sections.map { |eefps| eefps.to_builder.attributes! }
#    end
#  end

  def ensure_extraction_form_structure
    self.project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
          extraction: self,
          extraction_forms_projects_section: efps,
          link_to_type1: efps.link_to_type1.nil? ?
            nil :
            ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
              extraction: self,
              extraction_forms_projects_section: efps.link_to_type1
            )
        )
      end
    end
  end

  def results_section_ready_for_extraction?
    ExtractionsExtractionFormsProjectsSectionsType1
      .by_section_name_and_extraction_id_and_extraction_forms_project_id(
        'Arms',
        self.id,
        self.project.extraction_forms_projects.first.id).present? &&
    ExtractionsExtractionFormsProjectsSectionsType1
      .by_section_name_and_extraction_id_and_extraction_forms_project_id(
        'Outcomes',
        self.id,
        self.project.extraction_forms_projects.first.id).present?
  end

  # Returns a ActiveRecord::AssociationRelation.
  def find_eefps_by_section_type(section_name)
    self.extractions_extraction_forms_projects_sections
      .joins(extraction_forms_projects_section: :section)
      .where(sections: { name: section_name })
  end
end
