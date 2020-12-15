json.partial! 'api/v2/projects/project', locals: { project: @project }
json.key_questions @project.key_questions_projects.map(&:key_question),
  partial: 'api/v2/key_questions/key_question',
  as: :key_question
json.members @project.members,
  partial: 'api/v2/users/user',
  as: :user
json.extraction_template do
  extraction_forms_projects_sections = @project
    .extraction_forms_projects
    .first
    .extraction_forms_projects_sections
  json.sections extraction_forms_projects_sections,
    partial: 'api/v2/extraction_forms_projects_sections/extraction_forms_projects_section',
    as: :efps
end
json.extractions_meta_data @project.extractions,
  partial: 'api/v2/extractions/extraction',
  as: :extraction
