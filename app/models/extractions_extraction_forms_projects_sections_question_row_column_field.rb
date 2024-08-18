# == Schema Information
#
# Table name: eefps_qrcfs
#
#  id                                                      :integer          not null, primary key
#  extractions_extraction_forms_projects_sections_type1_id :integer
#  extractions_extraction_forms_projects_section_id        :integer
#  question_row_column_field_id                            :integer
#  name                                                    :text(65535)
#  created_at                                              :datetime         not null
#  updated_at                                              :datetime         not null
#

class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField < ApplicationRecord
  include SharedProcessTokenMethods

  attr_accessor :is_amoeba_copy

  self.table_name = 'eefps_qrcfs'

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  amoeba do
    enable

    customize(lambda { |original, copy| 
      copy.is_amoeba_copy = true
    })
  end

  belongs_to :extractions_extraction_forms_projects_sections_type1,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields, optional: true
  belongs_to :extractions_extraction_forms_projects_section,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields
  belongs_to :question_row_column_field,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields

  has_many :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
           dependent: :destroy,
           inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_field,
           foreign_key: 'eefps_qrcf_id'
  has_many :question_row_columns_question_row_column_options,
           through: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
           dependent: :destroy

  has_many :records, as: :recordable

  delegate :extraction, to: :extractions_extraction_forms_projects_section, allow_nil: true
  delegate :project, to: :extractions_extraction_forms_projects_section

  def question_row_columns_question_row_column_option_ids=(tokens)
    tokens.map do |token|
      resource = question_row_column_field.question_row_column.question_row_columns_question_row_column_options.build(question_row_column_option_id: 1)
      save_resource_name_with_token(resource, token)
    end
    super
  end

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    correct_eefpst1_association
    correct_qrcf_association
  end

  def correct_eefpst1_association
    extractions_extraction_forms_projects_sections_type1.update(extractions_extraction_forms_projects_section:) unless extractions_extraction_forms_projects_sections_type1.nil?
  end

  def correct_qrcf_association
    question_row_column_field.question_row_column.question_row.question.update(extraction_forms_projects_section: extractions_extraction_forms_projects_section.extraction_forms_projects_section)
  end
end
