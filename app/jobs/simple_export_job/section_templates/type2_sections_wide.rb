module SimpleExportJob::SectionTemplates::Type2SectionsWide
  def build_type2_sections_wide(kq_ids = [])
    # The main extraction form is always the first efp.
    efp = @project.extraction_forms_projects.first
    efp.extraction_forms_projects_sections.each do |efps|
      # If this is a type2 section then we proceed.
      next unless efps.extraction_forms_projects_section_type_id == 2

      # Add a new sheet.
      @package.workbook.add_worksheet(name: ensure_unique_sheet_name(efps.section.name.try(:truncate, 24))) do |sheet|
        # For each sheet we create a SheetInfo object.
        sheet_info = SimpleExportJob::SheetInfo.new(@project)

        # Every row represents an extraction.
        @project.extractions.each do |extraction|
          # Create base for extraction information.
          sheet_info.new_extraction_info(extraction)

          # Collect basic information about the extraction.
          sheet_info.set_extraction_info(
            extraction_id: extraction.id,
            consolidated: extraction.consolidated.to_s,
            username: extraction.username,
            citation_id: extraction.citation.id,
            citation_name: extraction.citation.name,
            authors: extraction.citation.authors
            publication_date: extraction.citation.try(:journal).try(:get_publication_year),
            refman: extraction.citation.refman,
            pmid: extraction.citation.pmid
          )

          eefps = efps.extractions_extraction_forms_projects_sections.find_or_create_by(
            extraction:,
            extraction_forms_projects_section: efps
          )

          # Iterate over each of the questions that are associated with this particular # extraction's
          # extraction_forms_projects_section and collect name and description.
          questions = efps.questions.joins(:key_questions_projects_questions)
                          .where(key_questions_projects_questions: {
                                   key_questions_project: KeyQuestionsProject.where(project: @project,
                                                                                    key_question_id: kq_ids)
                                 }).distinct.order(id: :asc)

          # If this section is linked we have to iterate through each occurrence of
          # type1 via eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.
          # Otherwise we proceed with eefpst1s set to a custom Struct that responds
          # to :id, type1: :id.
          eefpst1s = if eefps.extraction_forms_projects_section.try(:extraction_forms_projects_section_option).by_type1 &&
                        eefps.link_to_type1.present?
                       eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s
                     else
                       [Struct.new(:id, :type1).new(nil, Struct.new(:id).new(nil))]
                     end

          eefpst1s.each do |eefpst1|
            questions.each do |q|
              q.question_rows.each do |qr|
                qr.question_row_columns.each do |qrc|
                  sheet_info.add_question_row_column(
                    extraction_id: extraction.id,
                    section_name: efps.section.name.try(:singularize),
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
                    key_questions: q.key_questions_projects_questions.collect(&:key_questions_project).collect(&:key_question).collect(&:name).map(&:strip).join("\x0D\x0A"),
                    eefps_qrfc_values: eefps.eefps_qrfc_values(eefpst1.id, qrc)
                  )
                end # qr.question_row_columns.each do |qrc|
              end # q.question_rows.each do |qr|
            end # questions.each do |q|
          end # eefps.type1s.each do |eefpst1|
        end # @project.extractions.each do |extraction|

        # First the basic headers:
        header_elements = sheet_info.header_info
        header_elements = header_elements.concat(['Key Questions'])
        header_row = sheet.add_row(header_elements)

        # Next continue the header row by adding all type2s together.
        sheet_info.question_row_columns.each do |qrc|
          # Try to find the column that matches the identifier.
          found, column_idx = nil
          found, column_idx = SimpleExportJob::SheetInfo.find_column_idx_with_value(header_row,
                                                                                    "[Type1 ID: #{qrc[:type1_id]}][Question ID: #{qrc[:question_id]}][Field ID: #{qrc[:question_row_id]}x#{qrc[:question_row_column_id]}]")

          # Append to the header if this is new.
          next if found

          title  = ''
          title += "#{Type1.find(qrc[:type1_id]).short_name_and_description} - " unless qrc[:type1_id].blank?
          title += "#{qrc[:question_name]}"
          title += " - #{qrc[:question_row_name]}" if qrc[:question_row_name].present?
          title += " - #{qrc[:question_row_column_name]}" if qrc[:question_row_column_name].present?
          comment  = '.'
          comment += "\rDescription: \"#{qrc[:question_description]}\"" if qrc[:question_description].present?

          # Don't fetch question_row_column object from db unnecessarily.
          if qrc[:question_row_column_options].first.present? && ([5, 6, 7, 8,
                                                                   9].include? QuestionRowColumn.find(qrc[:question_row_column_id]).question_row_column_type_id)
            comment += "\rAnswer choices:"
            qrc[:question_row_column_options].each do |qrco|
              comment += "\r    [Option ID: #{qrco[0]}] #{qrco[1]}"
            end # qrc[:question_row_column_options].each do |qrco|
          end # if [5, 6, 7, 8, 9].include? QuestionRowColumn.find(qrc[:question_row_column_id]).question_row_column_type_id

          new_cell = header_row.add_cell "#{title}\r[Type1 ID: #{qrc[:type1_id]}][Question ID: #{qrc[:question_id]}][Field ID: #{qrc[:question_row_id]}x#{qrc[:question_row_column_id]}]"
          if qrc[:question_description].present? || qrc[:question_row_column_options].first.present?
            sheet.add_comment ref: new_cell, author: 'Export AI', text: comment,
                              visible: false
          end
          # unless found
        end # sheet_info.question_row_columns.each do |qrc|

        # Now we add the extraction rows.
        sheet_info.extractions.each do |_key, extraction|
          new_row = []
          new_row << extraction[:extraction_info][:extraction_id]
          new_row << extraction[:extraction_info][:consolidated]
          new_row << extraction[:extraction_info][:username]
          new_row << extraction[:extraction_info][:citation_id]
          new_row << extraction[:extraction_info][:citation_name]
          new_row << extraction[:extraction_info][:refman]
          new_row << extraction[:extraction_info][:pmid]
          new_row << extraction[:extraction_info][:authors]
          new_row << extraction[:extraction_info][:publication_date]
          new_row << extraction[:extraction_info][:key_questions]

          # Add question information.
          extraction[:question_row_columns].each do |qrc|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = SimpleExportJob::SheetInfo.find_column_idx_with_value(header_row,
                                                                                      "[Type1 ID: #{qrc[:type1_id]}][Question ID: #{qrc[:question_id]}][Field ID: #{qrc[:question_row_id]}x#{qrc[:question_row_column_id]}]")

            # Something is wrong if it wasn't found.
            unless found
              raise "Error: Could not find header row: [Type1 ID: #{qrc[:type1_id]}][Question ID: #{qrc[:question_id]}][Field ID: #{qrc[:question_row_id]}x#{qrc[:question_row_column_id]}]"
            end

            new_row[column_idx] = qrc[:eefps_qrfc_values]
          end # extraction[:questions].each do |q|

          # Done. Let's add the new row.
          sheet.add_row new_row
        end # sheet_info.extractions.each do |key, extraction|

        # Re-apply the styling for the new cells in the header row before closing the sheet.
        sheet.column_widths 16, 16, 16, 50, 16, 16
        header_row.style = @highlight
      end # END @package.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end
end
