# == Schema Information
#
# Table name: extractions
#
#  id                     :integer          not null, primary key
#  project_id             :integer
#  citations_project_id   :integer
#  projects_users_role_id :integer
#  consolidated           :boolean          default(FALSE)
#  deleted_at             :datetime
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

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
  after_create :create_default_arms

  # create checksums without delay after create and update, since extractions/index would be incorrect.
  after_create do |extraction|
    ExtractionChecksum.create! extraction: extraction
  end

  scope :by_project_and_user, -> ( project_id, user_id ) {
    joins(projects_users_role: { projects_user: :user })
    .where(project_id: project_id)
    .where(projects_users: { user_id: user_id })
  }

  scope :consolidated,   -> () { where(consolidated: true) }
  scope :unconsolidated, -> () { where(consolidated: false) }

  belongs_to :project,             inverse_of: :extractions, touch: true
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, inverse_of: :extractions

  has_one :extraction_checksum, dependent: :destroy, inverse_of: :extraction

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections, dependent: :destroy

  has_many :extractions_projects_users_roles, dependent: :destroy, inverse_of: :extraction

  has_many :extractions_key_questions_projects_selections, dependent: :destroy

  delegate :citation, to: :citations_project
  delegate :user, to: :projects_users_role

#  def to_builder
#    Jbuilder.new do |extraction|
#      extraction.sections extractions_extraction_forms_projects_sections.map { |eefps| eefps.to_builder.attributes! }
#    end
#  end

  def ensure_extraction_form_structure
    # self.project.extraction_forms_projects.includes([:extraction_forms_projects_sections, :extraction_form]).each do |efp|
    # NOTE This method assumes that self is not a mini-extraction
    efp = self.project.extraction_forms_projects.includes([:extraction_form]).first
    efp.extraction_forms_projects_sections.includes([:link_to_type1]).each do |efps|
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

  # There are two types of extraction forms:
  # 1. Standard
  # 2. Diagnostic Test
  #
  # Conditions for type 1. Standard results section to be ready for extraction:
  # a) Extraction contains Arms
  # b) Extraction contains Outcomes
  #
  # Conditions for type 2. Diagnostic Test results section to be ready for extraction:
  # a) Extraction contains Diagnostic Tests
  # b) Extraction contains Diagnoses
  def results_section_ready_for_extraction?
    efp_type_id = self.extraction_forms_projects_sections.first.extraction_forms_project.extraction_forms_project_type_id
    if efp_type_id.eql?(1)
      return ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Arms',
          self.id,
          self.project.extraction_forms_projects.first.id).present? &&
         ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Outcomes',
          self.id,
          self.project.extraction_forms_projects.first.id).present?
    elsif efp_type_id.eql?(2)
      return ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Diagnostic Tests',
          self.id,
          self.project.extraction_forms_projects.first.id).present? &&
         ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Diagnoses',
          self.id,
          self.project.extraction_forms_projects.first.id).present?
    end
  end

  # Returns a ActiveRecord::AssociationRelation.
  def find_eefps_by_section_type(section_name)
    extractions_extraction_forms_projects_sections
      .joins(extraction_forms_projects_section: :section)
      .find_by(sections: { name: section_name })
  end

  private

  def create_default_arms
#    find_eefps_by_section_type("Arms")
#      .type1s << Type1.find_or_create_by(name: 'Total', description: 'All interventions combined')
#    extractions_extraction_forms_projects_sections
#      .joins(extraction_forms_projects_section: :section)
#      .find_by(sections: { name: "Arms" }
#    ).type1s << Type1.find_or_create_by(name: 'Total', description: 'All interventions combined')
  end
end
