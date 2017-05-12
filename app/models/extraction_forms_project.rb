class ExtractionFormsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_form, inverse_of: :extraction_forms_projects
  belongs_to :project, inverse_of: :extraction_forms_projects

  has_many :extraction_forms_projects_sections, dependent: :destroy, inverse_of: :extraction_forms_project
  has_many :sections, through: :extraction_forms_projects_sections, dependent: :destroy
  has_many :key_questions_projects, dependent: :nullify, inverse_of: :extraction_forms_project
  has_many :key_questions, through: :key_questions_projects, dependent: :destroy

  accepts_nested_attributes_for :extraction_form, reject_if: :extraction_form_name_exists?
  accepts_nested_attributes_for :extraction_forms_projects_sections, allow_destroy: true, reject_if: :all_blank

  private

  def extraction_form_name_exists?(attributes)
    begin
      self.extraction_form = ExtractionForm.where(name: attributes[:name]).first_or_create!
    rescue ActiveRecord::RecordNotUnique
      retry
    end
#    if _extraction_form = ExtractionForm.find_by(name: attributes[:name])
#      # Associate this ExtractionFormsProject with the existing ExtractionForm.
#      self.extraction_form = _extraction_form
#      return true
#    else
#      return false
#    end
  end
end
