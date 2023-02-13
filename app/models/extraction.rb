# == Schema Information
#
# Table name: extractions
#
#  id                     :integer          not null, primary key
#  project_id             :integer
#  citations_project_id   :integer
#  projects_users_role_id :integer
#  consolidated           :boolean          default(FALSE)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  user_id                :integer
#

class Extraction < ApplicationRecord
  include ConsolidationHelper

  # !!! We can't implement this without ensuring integrity of the extraction form. It is possible that the database
  #    is rendered inconsistent if a project lead changes links between type1 and type2 after this hook is called.
  #    We need something that ensures consistency when linking is changed.
  #
  # Note: 6/25/2018 - We call ensure_extraction_form_structure in work and consolidate action. this might be enough
  #                   to ensure consistency?
  after_create :ensure_extraction_form_structure
  after_create :create_default_arms
  after_create :create_default_status
  after_save :evaluate_screening_status_citations_project

  # create checksums without delay after create and update, since extractions/index would be incorrect.
  after_create do |extraction|
    ExtractionChecksum.create! extraction:
  end

  scope :consolidated,   -> { where(consolidated: true) }
  scope :unconsolidated, -> { where(consolidated: false) }

  belongs_to :project,             inverse_of: :extractions # , touch: true
  belongs_to :citations_project,   inverse_of: :extractions
  belongs_to :projects_users_role, optional: true
  belongs_to :user,                optional: true

  has_one :extraction_checksum, dependent: :destroy, inverse_of: :extraction
  has_one :statusing, as: :statusable, dependent: :destroy
  has_one :status, through: :statusing

  has_many :extractions_extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction
  has_many :extraction_forms_projects_sections, through: :extractions_extraction_forms_projects_sections,
                                                dependent: :destroy

  has_many :extractions_key_questions_projects_selections, dependent: :destroy
  has_many :key_questions_projects, through: :extractions_key_questions_projects_selections

  delegate :citation, to: :citations_project
  delegate :username, to: :user, allow_nil: true

  #  def to_builder
  #    Jbuilder.new do |extraction|
  #      extraction.sections extractions_extraction_forms_projects_sections.map { |eefps| eefps.to_builder.attributes! }
  #    end
  #  end

  def set_stale(state)
    extraction_checksum.save
    extraction_checksum.is_stale = state
    extraction_checksum.save
  end

  def ensure_extraction_form_structure
    # self.project.extraction_forms_projects.includes([:extraction_forms_projects_sections, :extraction_form]).each do |efp|
    # NOTE This method assumes that self is not a mini-extraction
    efp = project.extraction_forms_projects.includes([:extraction_form]).first
    efp.extraction_forms_projects_sections.includes([:link_to_type1]).each do |efps|
      ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
        extraction: self,
        extraction_forms_projects_section: efps,
        link_to_type1: if efps.link_to_type1.nil?
                         nil
                       else
                         ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
                           extraction: self,
                           extraction_forms_projects_section: efps.link_to_type1
                         )
                       end
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
    return false if extraction_forms_projects_sections.blank?

    efp_type_id = extraction_forms_projects_sections.first.extraction_forms_project.extraction_forms_project_type_id
    if efp_type_id.eql?(1)
      ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Arms',
          id,
          project.extraction_forms_projects.first.id
        ).present? &&
        ExtractionsExtractionFormsProjectsSectionsType1
          .by_section_name_and_extraction_id_and_extraction_forms_project_id(
            'Outcomes',
            id,
            project.extraction_forms_projects.first.id
          ).present?
    elsif efp_type_id.eql?(2)
      ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Diagnostic Tests',
          id,
          project.extraction_forms_projects.first.id
        ).present? &&
        ExtractionsExtractionFormsProjectsSectionsType1
          .by_section_name_and_extraction_id_and_extraction_forms_project_id(
            'Diagnoses',
            id,
            project.extraction_forms_projects.first.id
          ).present?
    end
  end

  # Returns a ActiveRecord::AssociationRelation.
  def find_eefps_by_section_type(section_name)
    extractions_extraction_forms_projects_sections
      .joins(extraction_forms_projects_section: :section)
      .find_by(sections: { name: section_name })
  end

  def has_data?
    type1_eefpss = Extraction.get_type1_sections_in_extraction(self)
    Extraction.get_type2_sections_in_extraction(self).each do |type2_eefps|
      type2_eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.each do |eefps_qrcf|
        type1_eefpss.each do |type1_eefps|
          type1_eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
            values = type2_eefps.eefps_qrfc_values(eefpst1.id,
                                                   eefps_qrcf.question_row_column_field.question_row_column)
            return true if values.present?
          end
        end
        values = type2_eefps.eefps_qrfc_values(nil, eefps_qrcf.question_row_column_field.question_row_column)
        return true if values.present?
      end
    end

    false
  end

  def self.get_type1_sections_in_extraction(extraction)
    extraction.extractions_extraction_forms_projects_sections
              .joins(:extraction_forms_projects_section)
              .includes(extractions_extraction_forms_projects_sections_type1s: [
                          { extractions_extraction_forms_projects_sections_type1_rows: [
                            { result_statistic_sections: [
                              { comparisons: { comparate_groups: { comparates: { comparable_element: :comparable } } } },
                              { result_statistic_sections_measures: [
                                { tps_comparisons_rssms: [
                                  :timepoint,
                                  :records,
                                  { comparison: { comparate_groups: { comparates: { comparable_element: :comparable } } } }
                                ] },
                                { comparisons_arms_rssms: [
                                  { comparison: { comparate_groups: { comparates: { comparable_element: :comparable } } } },
                                  { extractions_extraction_forms_projects_sections_type1: [:extractions_extraction_forms_projects_section] },
                                  :records
                                ] },
                                { tps_arms_rssms: [
                                  :records,
                                  :timepoint,
                                  { extractions_extraction_forms_projects_sections_type1: :extractions_extraction_forms_projects_section }
                                ] },
                                { wacs_bacs_rssms: [
                                  :records,
                                  { wac: { comparate_groups: { comparates: { comparable_element: :comparable } } } },
                                  { bac: { comparate_groups: { comparates: { comparable_element: :comparable } } } }
                                ] }
                              ] }
                            ] },
                            :extractions_extraction_forms_projects_sections_type1_row_columns
                          ] },
                          :type1
                        ])
              .where(extraction_forms_projects_sections: { extraction_forms_projects_section_type_id: 1 })
  end

  def self.get_type2_sections_in_extraction(extraction)
    extraction.extractions_extraction_forms_projects_sections
              .joins(:extraction_forms_projects_section)
              .includes({ extractions_extraction_forms_projects_sections_question_row_column_fields: %i[
                          records
                          question_row_column_field
                          extractions_extraction_forms_projects_sections_type1
                        ] })
              .where(extraction_forms_projects_sections: { extraction_forms_projects_section_type_id: 2 })
  end

  def assigned_to?(member)
    user.eql?(member)
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

  def create_default_status
    self.status = Status.DRAFT if statusing.blank?
  end

  def evaluate_screening_status_citations_project
    return if citations_project.marked_for_destruction?

    citations_project.try(:evaluate_screening_status)
  end
end
