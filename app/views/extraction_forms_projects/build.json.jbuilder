key_questions_projects =
  @extraction_forms_project.project.key_questions_projects
json.array!(
  @extraction_forms_projects_sections
    .find_by(id: @panel_tab)
    .questions
    .includes(
      :dependencies,
      key_questions_projects: :key_question,
      question_rows: {
        question_row_columns: [
          :question_row_column_type,
          {
            question_row_columns_question_row_column_options: %i[
              question_row_column_option
              followup_field
            ],
          },
        ],
      },
    )
    .order(pos: :asc),
) do |question|
  json.position question.pos
  json.id question.id
  json.name question.name
  json.description question.description
  json.columns question.question_rows.first&.question_row_columns || []
  json.rows question.question_rows
  cells = {}
  question.question_rows.each_with_index do |question_row, question_row_index|
    question_row.question_row_columns
      .each_with_index do |question_row_column, question_row_column_index|
      cells[question_row_index] ||= {}
      cells[question_row_index][question_row_column_index] =
        question_row_column.form_object
    end
  end
  json.cells cells
  ds = []
  question.dependencies.each do |d|
    ds << "Question Position: #{d.prerequisitable.question.pos}"
    if d.prerequisitable.question.question_type == 'Matrix'
      if [5, 6, 7, 8, 9].include?(d.prerequisitable.question_row_column_type.id)
        ds <<
          '- Cell: (' + d.prerequisitable.question_row.name.to_s + ' x ' +
            d.prerequisitable.question_row_column.name.to_s + ')'
        ds << '- Option: ' + d.prerequisitable.name
      else
        ds <<
          '- Cell: (' + d.prerequisitable.question_row.name.to_s + ' x ' +
            d.prerequisitable.name.to_s + ')'
      end
    elsif [5, 6, 7, 8, 9].include?(
          d.prerequisitable.question_row_column_type.id,
        )
      ds << '- Option: ' + d.prerequisitable.name
    end
  end
  json.dependencies ds

  kqp_hash = {}
  question.key_questions_projects.each do |kqp|
    kqp_hash["#{question.id}-#{kqp.id}"] = true
  end
  json.key_questions_projects do
    json.array!(
      key_questions_projects.map do |kqp|
        {
          id: kqp.id,
          key_question: kqp.key_question,
          checked: !!kqp_hash["#{question.id}-#{kqp.id}"],
        }
      end,
    )
  end
end
