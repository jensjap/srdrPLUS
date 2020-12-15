question_type = qrc.question_row_column_type

json.id qrc.id
json.row qrc.question_row,
  partial: 'api/v2/question_rows/question_row',
  as: :row
json.col qrc,
  partial: 'api/v2/question_row_columns/question_row_column',
  as: :column
json.question_type question_type.name
if [
  QuestionRowColumnType::CHECKBOX,
  QuestionRowColumnType::DROPDOWN,
  QuestionRowColumnType::RADIO,
  QuestionRowColumnType::SELECT2_SINGLE,
  QuestionRowColumnType::SELECT2_MULTI
].include? question_type.name
  json.answer_options qrc
    .question_row_columns_question_row_column_options
    .joins(:question_row_column_option)
    .where('question_row_columns_question_row_column_options.question_row_column_option_id=?',
      QuestionRowColumnOption.find_by(name: QuestionRowColumnOption::ANSWER_CHOICE).id),
    partial: 'api/v2/question_row_column_options/question_row_column_option',
    as: :option
end