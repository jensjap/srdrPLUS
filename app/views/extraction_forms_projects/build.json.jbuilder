json.array! @extraction_forms_projects_sections.find_by(id: @panel_tab).questions.sort_by { |q|
  q.pos
} do |question|
  json.position question.pos
  json.id question.id
  json.name question.name
  json.description question.description
  ds = []
  question.dependencies.each do |d|
    ds << "Question Position: #{d.prerequisitable.question.pos}"
    if d.prerequisitable.question.question_type == 'Matrix'
      if [5, 6, 7, 8, 9].include?(d.prerequisitable.question_row_column_type.id)
        ds << '- Cell: (' + d.prerequisitable.question_row.name.to_s + ' x ' + d.prerequisitable.question_row_column.name.to_s + ')'
        ds << '- Option: ' + d.prerequisitable.name
      else
        ds << '- Cell: (' + d.prerequisitable.question_row.name.to_s + ' x ' + d.prerequisitable.name.to_s + ')'
      end
    elsif [5, 6, 7, 8, 9].include?(d.prerequisitable.question_row_column_type.id)
      ds << '- Option: ' + d.prerequisitable.name
    end
  end
  json.dependencies ds
  json.key_questions do
    json.array! question.key_questions_projects.map(&:key_question)
  end
end
