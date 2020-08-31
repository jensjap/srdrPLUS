namespace :question_row_column_type_tasks do
  task ensure_question_row_column_fields: [:environment] do
    QuestionRowColumn.all.each { |qrc| qrc.send(:ensure_question_row_column_fields) }
  end
end
