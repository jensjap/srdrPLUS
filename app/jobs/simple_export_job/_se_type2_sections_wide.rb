require 'simple_export_job/sheet_info'

def build_type2_sections_wide(p, project, highlight, wrap, kq_ids=[])
  # Type2 (Questions) are associated to Key Questions and we export by the KQ's selected.
  # If no KQ's array is passed in, we assume to export all.
  kq_ids = project.key_questions.collect(&:id) if kq_ids.blank?

  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a type2 section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 2

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) } - wide") do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # Every row represents an extraction.
          project.extractions.each do |extraction|
            # Create base for extraction information.
            sheet_info.new_extraction_info(extraction)

            # Collect basic information about the extraction.
            sheet_info.set_extraction_info(
              extraction_id: extraction.id,
              username: extraction.projects_users_role.projects_user.user.profile.username,
              citation_id: extraction.citations_project.citation.id,
              citation_name: extraction.citations_project.citation.name,
              refman: extraction.citations_project.citation.refman,
              pmid: extraction.citations_project.citation.pmid)
            eefps = efps.extractions_extraction_forms_projects_sections.find_by(
              extraction: extraction,
              extraction_forms_projects_section: efps)
            # Iterate over each of the questions that are associated with this particular # extraction's
            # extraction_forms_projects_section and collect name and description.
            questions = efps.questions.joins(:key_questions_projects_questions).where(key_questions_projects_questions: { key_questions_project: kq_ids }).distinct.order(id: :asc)
            questions.each do |q|
              sheet_info.add_question(
                extraction_id: extraction.id,
                section_name: efps.section.name.singularize,
                id: q.id,
                name: q.name,
                description: q.description)

              q.question_rows.each do |qr|
                qr.question_row_columns.each do |qrc|
                  sheet_info.add_question_row_column(
                    question_id: q.id,
                    question_row_id: qr.id,
                    question_row_name: qr.name,
                    question_row_column_id: qrc.id,
                    question_row_column_name: qrc.name,
                    question_
                    ;tabne
                  )
                end  # qr.question_row_columns.each do |qrc|
              end  # q.question_rows.each do |qr|
            end  # questions.each do |q|
          end  # project.extractions.each do |extraction|

          # Start printing rows to the spreadsheet. First the basic headers:
          #['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
          header_row = sheet.add_row sheet_info.header_info

          # Next continue the header row by adding all type2s together.
          sheet_info.questions.each do |q|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[#{ q[:section_name] } Question ID: #{ q[:id] }]")

            # Append to the header if this is new.
            unless found
              new_cell = header_row.add_cell "[#{ q[:section_name] } Question ID: #{ q[:id] }] #{ q[:name] }"
              sheet.add_comment ref: new_cell, author: 'Export AI', text: q[:description], visible: false if q[:description].present?
            end
          end  # sheet_info.questions.each do |q|

          # Now we add the extraction rows.
          sheet_info.extractions.each do |key, extraction|
            new_row = []
            new_row << extraction[:extraction_info][:extraction_id]
            new_row << extraction[:extraction_info][:username]
            new_row << extraction[:extraction_info][:citation_id]
            new_row << extraction[:extraction_info][:citation_name]
            new_row << extraction[:extraction_info][:refman]
            new_row << extraction[:extraction_info][:pmid]

            # Add question information.
            extraction[:questions].each do |q|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[#{ q[:section_name] } Question ID: #{ q[:id] }]")

              # Something is wrong if it wasn't found.
              unless found
                raise RuntimeError, "Error: Could not find header row: [#{ q[:section_name] } Question ID: #{ q[:id] }]"
              end

              new_row[column_idx] = q[:value]
            end  # extraction[:questions].each do |q|

            # Done. Let's add the new row.
            sheet.add_row new_row
          end  # sheet_info.extractions.each do |key, extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          #sheet.column_widths nil
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) } - wide") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 2
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
