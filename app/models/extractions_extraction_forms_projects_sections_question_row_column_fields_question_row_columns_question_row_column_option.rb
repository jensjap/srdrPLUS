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
  # !!! Don't quite remember what this is for. My best guess is that it is going to be used when we record multiple options for a particular record.
  # So used for select many options like checkboxes, select2-multi???
  self.table_name = 'eefpsqrcf_qrcqrcos'

  belongs_to :extractions_extraction_forms_projects_sections_question_row_column_field,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
             foreign_key: 'eefps_qrcf_id'
  belongs_to :question_row_columns_question_row_column_option,
             inverse_of: :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options
end
