module ProjectsHelper
  def list_of_key_questions(extraction_forms_project)
    if extraction_forms_project.key_questions_projects.present?
      html = '<ul>'
      extraction_forms_project.key_questions_projects.each do |kqp|
        html += "<li>#{kqp.key_question.name}</li>"
      end
      html += '</ul>'

      raw(html)
    end
  end

  def empty_or_na(attribute)
    attribute.present? ? attribute : 'N/A'
  end

  def add_submenu?(controller_name, action_name, controller, publishable_record)
    (controller_name.eql?('projects') && !action_name.eql?('index') && !action_name.eql?('new')) ||
      (controller_name.eql?('sd_meta_data') && (action_name.eql?('index') || action_name.eql?('show') || action_name.eql?('edit'))) ||
      controller_name.eql?('assignments') ||
      controller_name.eql?('abstract_screenings') ||
      controller_name.eql?('fulltext_screenings') ||
      controller_name.eql?('screening_forms') ||
      controller_name.eql?('extractions') ||
      controller_name.eql?('extraction_forms_projects') ||
      (controller_name.eql?('citations') && action_name.eql?('index')) ||
      (controller_name.eql?('tasks') && action_name.eql?('index')) ||
      (controller_name.eql?('screening_options') && action_name.eql?('index')) ||
      (controller_name.eql?('questions') && (action_name.eql?('dependencies') ||
      action_name.eql?('edit'))) ||
      (controller_name.eql?('extractions_extraction_forms_projects_sections_type1s') && action_name.eql?('edit')) ||
      (controller_name.eql?('extraction_forms_projects_sections') && action_name.eql?('preview')) ||
      (controller_name.eql?('imports') && (action_name.eql?('new') || action_name.eql?('index'))) ||
      (controller.instance_of?(PublishingsController) && publishable_record.instance_of?(Project) && controller.action_name == 'new') ||
      (controller_name.eql?('consolidations') && action_name.eql?('index'))
  end

  def find_project(project, extraction, extraction_forms_project, question, extraction_forms_projects_section, publishable_record)
    project ||
      extraction.try(:project) ||
      extraction_forms_project.try(:project) ||
      question.try(:project) ||
      extraction_forms_projects_section.try(:project) ||
      publishable_record
  end
end
