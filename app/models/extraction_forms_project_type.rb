# == Schema Information
#
# Table name: extraction_forms_project_types
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExtractionFormsProjectType < ApplicationRecord
  STANDARD = 'Standard'.freeze
  DIAGNOSTIC_TEST = 'Diagnostic Test'.freeze
  MINI_EXTRACTION = 'Citation Screening Extraction Form'.freeze

  acts_as_paranoid

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :extraction_forms_project_type

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
