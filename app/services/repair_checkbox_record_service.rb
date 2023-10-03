# frozen_string_literal: true

class RepairCheckboxRecordService
  def self.repair!
    checkbox_question_row_column_type = QuestionRowColumnType
                                        .find_by(name: QuestionRowColumnType::CHECKBOX)
    qrcs = QuestionRowColumn.where(question_row_column_types: checkbox_question_row_column_type)

    query = "
SELECT
  *
FROM records
JOIN eefps_qrcfs
  ON records.recordable_id=eefps_qrcfs.id
JOIN question_row_column_fields
  ON eefps_qrcfs.question_row_column_field_id=question_row_column_fields.id
JOIN question_row_columns
  ON question_row_column_fields.question_row_column_id=question_row_columns.id
WHERE recordable_type='ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField'
  AND question_row_columns.question_row_column_type_id=5;
"
    results = ActiveRecord::Base.connection.exec_query(query, 'SQL')
  end
end
