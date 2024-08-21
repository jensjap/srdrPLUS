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
  attr_accessor :is_amoeba_copy

  amoeba do
    enable

    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  belongs_to :extractions_extraction_forms_projects_section, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields
  belongs_to :extractions_extraction_forms_projects_sections_type1, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields, optional: true
  belongs_to :followup_field, inverse_of: :extractions_extraction_forms_projects_sections_followup_fields

  has_many :records, as: :recordable

  delegate :extraction, to: :extractions_extraction_forms_projects_section

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    # Placeholder for debugging. No corrections needed.
  end
end
