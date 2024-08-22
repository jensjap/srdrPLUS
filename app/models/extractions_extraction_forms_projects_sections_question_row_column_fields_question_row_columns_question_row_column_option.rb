# == Schema Information
#
# Table name: eefpsqrcf_qrcqrcos
#
#  id                                                 :integer          not null, primary key
#  eefps_qrcf_id                                      :integer
#  question_row_columns_question_row_column_option_id :integer
#  created_at                                         :datetime         not null
#  updated_at                                         :datetime         not null
#

class ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption < ApplicationRecord
  attr_accessor :is_amoeba_copy

  self.table_name = 'eefpsqrcf_qrcqrcos'

  before_commit :correct_parent_associations, if: :is_amoeba_copy

  amoeba do
    enable

    customize(lambda { |_, copy|
      copy.is_amoeba_copy = true
    })
  end

  belongs_to :extractions_extraction_forms_projects_sections_question_row_column_field,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
             foreign_key: 'eefps_qrcf_id'
  belongs_to :question_row_columns_question_row_column_option,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options

  private

  def correct_parent_associations
    return unless is_amoeba_copy

    correct_qrcqrco_association
  end

  def correct_qrcqrco_association
    # qrcqrcos = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption
    qrcqrcos = QuestionRowColumnsQuestionRowColumnOption
                 .joins(
                   question_row_column: {
                     question_row: {
                       question: {
                         extraction_forms_projects_section: {
                           extraction_forms_project: :project
                         }
                       }
                     }
                   }
                 )
                 .where(
                   question_row_column: extractions_extraction_forms_projects_sections_question_row_column_field.question_row_column_field.question_row_column,
                   question_row_column_option: question_row_columns_question_row_column_option.question_row_column_option,
                   extraction_forms_projects: {
                     project: extractions_extraction_forms_projects_sections_question_row_column_field
                                .extractions_extraction_forms_projects_section
                                .extraction
                                .project
                   }
                 )
    raise unless qrcqrcos.size.eql?(1)

    update(question_row_columns_question_row_column_option: qrcqrcos[0])
  end
end
