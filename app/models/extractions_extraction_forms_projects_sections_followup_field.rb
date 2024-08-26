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

    correct_eefpst1_association
    correct_followup_field_association
  end

  def correct_eefpst1_association
    return unless extractions_extraction_forms_projects_sections_type1

    eefpst1s = ExtractionsExtractionFormsProjectsSectionsType1.where(
                 type1_type: extractions_extraction_forms_projects_sections_type1.type1_type,
                 extractions_extraction_forms_projects_section: extractions_extraction_forms_projects_section.link_to_type1,
                 type1: extractions_extraction_forms_projects_sections_type1.type1)
    raise unless eefpst1s.size.eql?(1)

    update(extractions_extraction_forms_projects_sections_type1: eefpst1s[0])
  end

  def correct_followup_field_association
    ffs = followup_field
            .amoeba_copies
            .joins(
              question_row_columns_question_row_column_option: {
                question_row_column: {
                  question_row: {
                    question: {
                      extraction_forms_projects_section: {
                        extraction_forms_project: :project
                      }
                    }
                  }
                }
              }
            ).where(
              amoeba_source_object: followup_field,
              extraction_forms_projects: {
                project: extraction.project
              }
            )
    raise unless ffs.size.eql?(1)

    update(followup_field: ffs[0])
  end
end
