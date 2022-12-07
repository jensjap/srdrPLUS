# == Schema Information
#
# Table name: extraction_forms_projects
#
#  id                               :integer          not null, primary key
#  extraction_forms_project_type_id :integer
#  extraction_form_id               :integer
#  project_id                       :integer
#  public                           :boolean          default(FALSE)
#  deleted_at                       :datetime
#  active                           :boolean
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#

class ExtractionFormsProject < ApplicationRecord
  STANDARD_SECTIONS = [
    'Arms',
    'Arm Details',
    'Outcomes',
    'Outcome Details'
  ].freeze
  DIAGNOSTIC_TEST_SECTIONS = [
    'Diagnostic Tests',
    'Diagnostic Test Details',
    'Diagnoses',
    'Diagnosis Details'
  ].freeze

  attr_accessor :create_empty

  # Get all ExtractionFormsProject items that are linked to a particular Extraction.
  # scope :by_extraction, -> (extraction_id) {
  #  joins(extraction_forms_projects_sections: { key_questions_projects: :extractions })
  #    .where(extractions: { id: extraction_id })
  #    .distinct
  # }

  scope :standard_types, lambda {
                           where(extraction_forms_project_type: ExtractionFormsProjectType.find_by_name(ExtractionFormsProjectType::STANDARD))
                         }
  scope :diagnostic_test_types, lambda {
                                  where(extraction_forms_project_type: ExtractionFormsProjectType.find_by_name(ExtractionFormsProjectType::DIAGNOSTIC_TEST))
                                }
  scope :mini_extraction_types, lambda {
                                  where(extraction_forms_project_type: ExtractionFormsProjectType.find_by_name(ExtractionFormsProjectType::MINI_EXTRACTION))
                                }

  after_create :create_default_sections, unless: :create_empty
  after_create :create_default_arms, unless: :create_empty
  after_update :ensure_proper_sections

  # Since has_many :extraction_forms_projects_sections uses lambda function to
  # scope efps by efp.extraction_forms_project_type declaring dependent: :destroy
  # on the has_many relationship will not find and destroy all of the efps.
  # We need to destroy them manually using pure sql to find all the relevant efps.
  before_destroy :destroy_extraction_forms_projects_sections

  belongs_to :extraction_forms_project_type, inverse_of: :extraction_forms_projects, optional: true
  belongs_to :extraction_form,               inverse_of: :extraction_forms_projects
  belongs_to :project,                       inverse_of: :extraction_forms_projects # , touch: true

  has_many :extraction_forms_projects_sections,
           lambda { |extraction_forms_project|
             case extraction_forms_project.extraction_forms_project_type_id
             when 1
               where(section: [Section.where('sections.name NOT IN (?)',
                                             DIAGNOSTIC_TEST_SECTIONS)]).ordered
             when 2
               where(section: [Section.where('sections.name NOT IN (?)',
                                             STANDARD_SECTIONS)]).ordered
             else
               ordered
             end
           },
           inverse_of: :extraction_forms_project
  has_many :key_questions_projects,
           -> { joins(extraction_forms_projects_section: :ordering) },
           through: :extraction_forms_projects_sections, dependent: :destroy
  has_many :sections,
           -> { joins(extraction_forms_projects_sections: :ordering) },
           through: :extraction_forms_projects_sections, dependent: :destroy

  accepts_nested_attributes_for :extraction_form, reject_if: :extraction_form_name_exists?

  def get_extraction_forms_project_extraction_form_information_markup
    extraction_form.name
  end

  # Use first section by default.
  def default_section_id
    extraction_forms_projects_sections.try(:first).try(:id)
  end

  private

  def destroy_extraction_forms_projects_sections
    ExtractionFormsProjectsSection
      .where(extraction_forms_project: self)
      .each(&:destroy)
  end

  def create_default_sections
    if extraction_forms_project_type.eql?(ExtractionFormsProjectType.find_by(name: 'Standard'))
      Section.default_sections.each do |section|
        ExtractionFormsProjectsSection.create(
          {
            extraction_forms_project: self,
            extraction_forms_projects_section_type: if ['Key Questions',
                                                        'Results'].include?(section.name)
                                                      ExtractionFormsProjectsSectionType.find_by(name: section.name)
                                                    elsif %w[Arms
                                                             Outcomes].include?(section.name)
                                                      ExtractionFormsProjectsSectionType.find_by(name: 'Type 1')
                                                    elsif ['Design Details', 'Arm Details',
                                                           'Sample Characteristics', 'Outcome Details', 'Risk of Bias Assessment'].include?(section.name)
                                                      ExtractionFormsProjectsSectionType.find_by(name: 'Type 2')
                                                    else
                                                      raise('Unexpected default section')
                                                    end,
            section:,
            link_to_type1: if ['Arm Details',
                               'Sample Characteristics'].include?(section.name)
                             ExtractionFormsProjectsSection.find_by(extraction_forms_project: self,
                                                                    extraction_forms_projects_section_type: ExtractionFormsProjectsSectionType.find_by(name: 'Type 1'), section: Section.find_by(name: 'Arms'))
                           elsif ['Outcome Details'].include?(section.name)
                             ExtractionFormsProjectsSection.find_by(extraction_forms_project: self,
                                                                    extraction_forms_projects_section_type: ExtractionFormsProjectsSectionType.find_by(name: 'Type 1'), section: Section.find_by(name: 'Outcomes'))
                           end
          }
        ).extraction_forms_projects_section_option.update!(
          by_type1: if ['Arm Details',
                        'Outcome Details'].include?(section.name)
                      true
                    else
                      ['Sample Characteristics'].include?(section.name) ? true : false
                    end,
          include_total: if ['Arm Details',
                             'Outcome Details'].include?(section.name)
                           false
                         else
                           ['Sample Characteristics'].include?(section.name) ? true : false
                         end
        )
      end

    elsif extraction_forms_project_type.eql?(ExtractionFormsProjectType.find_by(name: 'Citation Screening Extraction Form'))
      ['Acceptance Reasons', 'Deferment Reasons', 'Rejection Reasons'].each do |name|
        extraction_forms_projects_sections.create(
          extraction_forms_projects_section_type: ExtractionFormsProjectsSectionType.find_by(name: 'Type 2'),
          section: Section.find_or_create_by(name:),
          link_to_type1: nil
        )
      end

    elsif extraction_forms_project_type.eql?(ExtractionFormsProjectType.find_by(name: 'Full Text Screening Extraction Form'))
      # Placeholder

    else
      raise 'Unknown ExtractionFormsProjectType'

    end
  end

  def create_default_arms
    if extraction_forms_project_type.eql?(ExtractionFormsProjectType.find_by(name: 'Standard'))
      extraction_forms_projects_sections.find_by(
        section: Section.find_by(name: 'Arms')
      ).type1s << Type1.find_or_create_by(name: 'Total', description: 'All Arms combined')
    end
  end

  def extraction_form_name_exists?(attributes)
    return true if attributes[:name].blank?

    begin
      self.extraction_form = ExtractionForm.where(name: attributes[:name]).first_or_create!
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end

  def ensure_proper_sections
    sections_for_efp_type2 if extraction_forms_project_type_id.eql?(2)
  end

  def sections_for_efp_type2
    DIAGNOSTIC_TEST_SECTIONS.each do |section_name|
      ExtractionFormsProjectsSection.find_or_create_by(
        {
          extraction_forms_project: self,
          extraction_forms_projects_section_type: if ['Diagnostic Tests',
                                                      'Diagnoses'].include?(section_name)
                                                    ExtractionFormsProjectsSectionType.find_by(name: 'Type 1')
                                                  elsif ['Diagnostic Test Details',
                                                         'Diagnosis Details'].include?(section_name)
                                                    ExtractionFormsProjectsSectionType.find_by(name: 'Type 2')
                                                  else
                                                    raise('Unexpected default section')
                                                  end,
          section: Section.find_or_create_by(name: section_name),
          link_to_type1: if ['Diagnostic Test Details'].include?(section_name)
                           ExtractionFormsProjectsSection.find_by(extraction_forms_project: self,
                                                                  extraction_forms_projects_section_type: ExtractionFormsProjectsSectionType.find_by(name: 'Type 1'), section: Section.find_by(name: 'Diagnostic Tests'))
                         elsif ['Diagnosis Details'].include?(section_name)
                           ExtractionFormsProjectsSection.find_by(extraction_forms_project: self,
                                                                  extraction_forms_projects_section_type: ExtractionFormsProjectsSectionType.find_by(name: 'Type 1'), section: Section.find_by(name: 'Diagnoses'))
                         end
        }
      )
    end
  end
end
