class Section < ApplicationRecord
  include SharedSuggestableMethods

  acts_as_paranoid
  has_paper_trail

  has_many :extraction_forms_projects_sections, dependent: :destroy, inverse_of: :section
  has_many :extraction_forms_projects, through: :extraction_forms_projects_sections, dependent: :destroy
end
