json.extract! extraction, :project_id, :citations_project_id, :projects_users_role_id

json.sections extraction.extractions_extraction_forms_projects_sections do |eefps|
  if eefps.extraction_forms_projects_section.extraction_forms_projects_section_type_id == 1
    json.name eefps.extraction_forms_projects_section.section.name
    json.type1s eefps.extractions_extraction_forms_projects_sections_type1s do |eefpst1|
      json.id eefpst1.type1.id
      json.name eefpst1.type1.name
      json.description eefpst1.type1.description
    end

  elsif eefps.extraction_forms_projects_section.extraction_forms_projects_section_type_id == 2
    json.name eefps.extraction_forms_projects_section.section.name
    json.questions eefps.extraction_forms_projects_section.questions do |q|
      q.question_rows.each do |qr|
        qr.question_row_columns.each do |qrc|
          qrc.question_row_column_fields.each do |qrcf|
            # If this section is linked we have to iterate through each occurrence of
            # type1 via eefps.extractions_extraction_forms_projects_sections_type1s.
            # Otherwise we proceed with eefpst1s set to a custom Struct that responds
            # to :id, type1: :id.
            eefpst1s = eefps.link_to_type1.present? ?
              eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s :
              [Struct.new(:id, :type1).new(nil, Struct.new(:id).new(nil))]
            json.type1s eefpst1s do |eefpst1|
              json.id eefpst1.type1.id
              json.answers eefps.eefps_qrfc_values(eefpst1.id, qrc)
            end
          end
        end
      end
    end

  elsif eefps.extraction_forms_projects_section.extraction_forms_projects_section_type_id == 3
    json.name eefps.extraction_forms_projects_section.section.name

  else
    raise RuntimeError, 'Undefined section type'
  end
end
