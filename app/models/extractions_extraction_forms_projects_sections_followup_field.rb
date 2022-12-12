# == Schema Information
#
# Table name: extractions_extraction_forms_projects_sections_followup_fields
#
#  id                                                      :bigint           not null, primary key
#  extractions_extraction_forms_projects_section_id        :bigint
#  followup_field_id                                       :bigint
#  created_at                                              :datetime         not null
#  updated_at                                              :datetime         not null
#  extractions_extraction_forms_projects_sections_type1_id :bigint
#
class ExtractionsExtractionFormsProjectsSectionsFollowupField < ApplicationRecord
  belongs_to :extractions_extraction_forms_projects_section,
             inverse_of: :extractions_extraction_forms_projects_sections_followup_fields
  belongs_to :extractions_extraction_forms_projects_sections_type1,
             inverse_of: :extractions_extraction_forms_projects_sections_followup_fields, optional: true
  belongs_to :followup_field, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields

  has_many :records, as: :recordable

  delegate :extraction, to: :extractions_extraction_forms_projects_section
end
