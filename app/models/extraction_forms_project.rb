class ExtractionFormsProject < ApplicationRecord
  include SharedParanoiaMethods

  acts_as_paranoid column: :active, sentinel_value: true
  has_paper_trail

  belongs_to :extraction_form, inverse_of: :extraction_forms_projects
  belongs_to :project, inverse_of: :extraction_forms_projects

  accepts_nested_attributes_for :extraction_form, reject_if: :extraction_form_name_exists?

  private

  def extraction_form_name_exists?(attributes)
    if _extraction_form = ExtractionForm.find_by(name: attributes[:name])
      # Associate this ExtractionFormsProject with the existing ExtractionForm.
      self.extraction_form = _extraction_form
      return true
    else
      return false
    end
  end
end
