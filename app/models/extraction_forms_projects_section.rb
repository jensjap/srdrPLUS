class ExtractionFormsProjectsSection < ApplicationRecord
  include SharedProcessTokenMethods
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_forms_project, inverse_of: :extraction_forms_projects_sections
  belongs_to :section, inverse_of: :extraction_forms_projects_sections

  has_many :questions, dependent: :destroy, inverse_of: :extraction_forms_projects_section

  accepts_nested_attributes_for :questions, reject_if: :all_blank
  accepts_nested_attributes_for :section, reject_if: :section_name_exists?

  def section_id=(token)
    process_token(token, :section)
    super
  end

  private

  def section_name_exists?(attributes)
    begin
      self.section = Section.where(name: attributes[:name]).first_or_create!
    rescue ActiveRecord::RecordNotUnique
      retry
    end
  end
end
