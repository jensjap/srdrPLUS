class ExtractionFormType < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  has_many :extraction_forms, dependent: :destroy, inverse_of: :extraction_form_type

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end

