# == Schema Information
#
# Table name: sections
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  default    :boolean          default(FALSE)
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Section < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  scope :default_sections, -> { where(default: true) }

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects_sections, dependent: :destroy, inverse_of: :section

  validates :name, presence: true, uniqueness: { case_sensitive: false }
end
