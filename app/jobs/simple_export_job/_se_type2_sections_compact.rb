require 'simple_export_job/sheet_info'

def build_type2_sections_compact(p, project, highlight, wrap, kq_ids=[])
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a type2 section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 2

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(21) } - compact") do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # Extractions can span multiple rows.
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
            questions = efps.questions.joins(:key_questions_projects_questions)
              .where(key_questions_projects_questions: { key_questions_project: KeyQuestionsProject.where(project: project, key_question_id: kq_ids) }).distinct.order(id: :asc)

            # If this section is linked we have to iterate through each occurrence of
            # type1 via eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.
            # Otherwise we proceed with eefpst1s set to a custom Struct that responds
            # to :id, type1: :id.
            eefpst1s = (eefps.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1 and eefps.link_to_type1.present?) ? 
              eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s :
              [Struct.new(:id, :type1).new(nil, Struct.new(:id).new(nil))]

            eefpst1s.each do |eefpst1|
              questions.each do |q|
                q.question_rows.each do |qr|
                  qr.question_row_columns.each do |qrc|
                    sheet_info.add_question_row_column(
                      extraction_id: extraction.id,
                      section_name: efps.section.name.singularize,
                      type1_id: eefpst1.type1.id,
                      question_id: q.id,
                      question_name: q.name,
                      question_description: q.description,
                      question_row_id: qr.id,
                      question_row_name: qr.name,
                      question_row_column_id: qrc.id,
                      question_row_column_name: qrc.name,
                      question_row_column_options: qrc
                      .question_row_columns_question_row_column_options
                      .where(question_row_column_option_id: 1)
                      .pluck(:id, :name),
                      eefps_qrfc_values: eefps.eefps_qrfc_values(eefpst1.id, qrc))
                  end  # qr.question_row_columns.each do |qrc|
                end  # q.question_rows.each do |qr|
              end  # questions.each do |q|
            end  # eefps.type1s.each do |eefpst1|
          end  # project.extractions.each do |extraction|

          # Start printing rows to the spreadsheet. First the basic headers:
          #['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
          header_row = sheet.add_row sheet_info.header_info.concat ['Arm Name', 'Arm Description', 'Question Text', 'Question Description', 'Question Options', 'Question Answer Value']

          # Now we add the extraction rows.
          sheet_info.extractions.each do |key, extraction|
            eefps = efps.extractions_extraction_forms_projects_sections.find_by(
              extraction: Extraction.find(extraction[:extraction_info][:extraction_id]),
              extraction_forms_projects_section: efps)

            # Iterate over each of the questions that are associated with this particular # extraction's
            # extraction_forms_projects_section and collect name and description.
            questions = efps.questions.joins(:key_questions_projects_questions)
              .where(key_questions_projects_questions: { key_questions_project: KeyQuestionsProject.where(project: project, key_question_id: kq_ids) }).distinct.order(id: :asc)

            # If this section is linked we have to iterate through each occurrence of
            # type1 via eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.
            # Otherwise we proceed with eefpst1s set to a custom Struct that responds
            # to :id, type1: :id.
            eefpst1s = (eefps.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1 and eefps.link_to_type1.present?) ? 
              eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s :
              [Struct.new(:id, :type1).new(nil, Struct.new(:id).new(nil))]

            if eefpst1s.first.is_a? Struct
              efps.questions.each do |question|
                new_row = []
                new_row << extraction[:extraction_info][:extraction_id]
                new_row << extraction[:extraction_info][:username]
                new_row << extraction[:extraction_info][:citation_id]
                new_row << extraction[:extraction_info][:citation_name]
                new_row << extraction[:extraction_info][:refman]
                new_row << extraction[:extraction_info][:pmid]
                new_row << 'Total'
                new_row << ''
                new_row << question.name
                new_row << question.description
                new_row << ([5, 6, 7, 8, 9].include?(question.question_rows.first.question_row_columns.first.question_row_column_type.id) ?
                  question.question_rows.first.question_row_columns.first.question_row_columns_question_row_column_options.where(question_row_column_option_id: 1).collect(&:name) :
                  "")
                eefpsqrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_by(
                  extractions_extraction_forms_projects_section: eefps,
                  question_row_column_field: question.question_rows.first.question_row_columns.first.question_row_column_fields.first
                )
                new_row << (eefpsqrcf.nil? ? "" : eefpsqrcf.records.first.name)

                sheet.add_row new_row
              end  # END questions.each do |question|

            else
              eefpst1s.each do |eefpst1|
                eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
                  eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|

                    #!!!

                  end  # END eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
                end  # END eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
              end  # END eefpst1s.each do |eefpst1|
            end  # END if eefpst1s.is_a? Struct

          end  # END sheet_info.extractions.each do |key, extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths nil
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(21) } - compact") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 2
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
