class ExtractionFormsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  after_create :create_default_sections

  belongs_to :extraction_form, inverse_of: :extraction_forms_projects
  belongs_to :extraction_forms_project_type, inverse_of: :extraction_forms_projects
  belongs_to :project, inverse_of: :extraction_forms_projects

  has_many :extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction_forms_project
  has_many :key_questions_projects, through: :extraction_forms_projects_sections, dependent: :destroy
  has_many :sections, through: :extraction_forms_projects_sections, dependent: :destroy

  accepts_nested_attributes_for :extraction_form, reject_if: :extraction_form_name_exists?

  private

  def create_default_sections
    Section.where(default: true).each do |section|
      ExtractionFormsProjectsSection.create(
        {
          extraction_forms_project: self,
          extraction_forms_projects_section_type: ['Key Questions'].include?(section.name) ?
          ExtractionFormsProjectsSectionType.find_by(name: section.name) : ['Arms', 'Outcomes'].include?(section.name) ?
          ExtractionFormsProjectsSectionType.find_by(name: 'Type 1') : ['Arm Details', 'Outcome Details', 'Quality'].include?(section.name) ?
          ExtractionFormsProjectsSectionType.find_by(name: 'Type 2') : ['Results'].include?(section.name) ?
          ExtractionFormsProjectsSectionType.find_by(name: 'Type 3') : raise('Unexpected default section'),
          section: section
        }
      )
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
end
