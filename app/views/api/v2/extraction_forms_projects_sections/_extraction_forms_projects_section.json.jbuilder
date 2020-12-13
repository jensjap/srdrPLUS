section_type = efps.extraction_forms_projects_section_type

json.id efps.section_id
json.name efps.section.name
json.type section_type.name
json.hidden efps.hidden
json.created_at efps.created_at
json.updated_at efps.updated_at

if section_type.name.eql?(ExtractionFormsProjectsSectionType::TYPE2)
  json.questions efps.questions,
    partial: 'api/v2/questions/question',
    as: :question
end