module ProjectsHelper
  def list_of_key_questions(extraction_forms_project)
    html = '<ul>'
    extraction_forms_project.key_questions_projects.each do |kqp|
      html += "<li>#{ kqp.key_question.name }</li>"
    end
    html += '</ul>'

    return raw(html)
  end
end
