associated_key_questions = question
  .key_questions_projects_questions
  .includes(key_questions_project: :key_question)
  .map(&:key_questions_project)
  .map(&:key_question)
first_row    = question.question_rows.first
first_column = first_row.question_row_columns.first
all_cells    = []
question.question_rows.each do |qr|
  qr.question_row_columns.each do |qrc|
    all_cells << qrc
  end
end

json.id question.id
json.key_questions associated_key_questions,
  partial: 'api/v2/key_questions/key_question',
  as: :key_question
json.name question.name
json.instructions question.description
json.url api_v2_question_url(question, format: :json)
json.question_structure do
  json.rows question.question_rows,
    partial: 'api/v2/question_rows/question_row',
    as: :row
  json.columns first_row.question_row_columns,
    partial: 'api/v2/question_row_columns/question_row_column',
    as: :column
  json.cells all_cells,
    partial: 'api/v2/question_row_columns/question_cell',
    as: :qrc
end
