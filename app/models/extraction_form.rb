# == Schema Information
#
# Table name: extraction_forms
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ExtractionForm < ApplicationRecord
  include SharedPublishableMethods
  include SharedSuggestableMethods

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects, dependent: :destroy, inverse_of: :extraction_form
  has_many :projects,               through: :extraction_forms_projects, dependent: :destroy
  has_many :key_questions_projects, through: :extraction_forms_projects, dependent: :destroy
  has_many :key_questions,          through: :extraction_forms_projects, dependent: :destroy

  validates :name, presence: true, uniqueness: { case_sensitive: true }
end
