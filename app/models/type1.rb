# == Schema Information
#
# Table name: type1s
#
#  id          :integer          not null, primary key
#  name        :string(255)
#  description :text(65535)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Type1 < ApplicationRecord
  include SharedQueryableMethods
  include SharedSuggestableMethods

  scope :uniq_by_section_name_and_not_included_in_efps, lambda { |efps_id|
    efps = ExtractionFormsProjectsSection.find(efps_id)
    joins(extraction_forms_projects_sections_type1s: { extraction_forms_projects_section: :section })
      .where(sections: { name: efps.section.name })
      .where.not(extraction_forms_projects_sections_type1s: { type1: efps.type1s })
      .distinct
  }

  after_create :record_suggestor

  has_one :suggestion, as: :suggestable, dependent: :destroy

  has_many :extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extraction_forms_projects_sections, through: :extraction_forms_projects_sections_type1s, dependent: :destroy

  has_many :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy, inverse_of: :type1
  has_many :extractions_extraction_forms_projects_sections,
           through: :extractions_extraction_forms_projects_sections_type1s, dependent: :destroy

  delegate :project, to: :extraction_forms_projects_section

  validates :description, uniqueness: { scope: :name }

  def name_and_description
    if name.present? && description.present?
      "#{name} (#{description})"
    elsif name.present?
      name
    else
      ''
    end
  end

  def short_name_and_description
    if description.present? && description.length < 10
      name_and_description
    elsif name.present? && description.present?
      "#{name} (#{description.truncate(16, separator: /\s/)})"
    elsif name.present?
      name
    else
      ''
    end
  end

  def pretty_print_export_header
    short_name_and_description
  end
end
