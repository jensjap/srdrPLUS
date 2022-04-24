require 'simple_export_job/sheet_info'

module Type2SectionsWideSRDRStyle
  def build_type2_sections_wide_srdr_style(kq_ids=[], print_empty_row=false)

    # The main extraction form is always the first efp.
    efp = @project.extraction_forms_projects.first
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a type2 section then we proceed.
      next unless efps.extraction_forms_projects_section_type_id == 2

      # Add a new sheet.
      @package.workbook.add_worksheet(name: ensure_unique_sheet_name(efps.section.name.try(:truncate, 24))) do |sheet|

        # For each sheet we create a SheetInfo object.
        sheet_info = SheetInfo.new(@project)
        sheet_info.populate!(:type2, kq_ids, efp, efps)

        # First the basic headers:
        header_elements = sheet_info.header_info

        # Add additional column headers to capture the link_to_type1 name and description
        # if link_to_type1 is present and add to header_elements.
        if efps.link_to_type1
          header_elements = header_elements.concat [
            "#{ efps.link_to_type1.section.name.try(:singularize) } Name",
            "#{ efps.link_to_type1.section.name.try(:singularize) } Description"
          ]
        end

        # Instantiate proper header Axlsx::Row element.
        header_row = sheet.add_row header_elements

        # Next continue the header row by adding all type2s together.
        sheet_info.question_row_columns.each do |qrc|
          # Try to find the column that matches the identifier.
          found, column_idx = nil
          found, column_idx = SheetInfo.find_column_idx_with_value(header_row,
            "[Question ID: #{ qrc[:question_id] }][Field ID: #{ qrc[:question_row_id] }x#{ qrc[:question_row_column_id] }]")

          # Append to the header if this is new.
          unless found
            title  = ''
            title += "#{ qrc[:question_name] }"
            title += " - #{ qrc[:question_row_name] }" if qrc[:question_row_name].present?
            title += " - #{ qrc[:question_row_column_name] }" if qrc[:question_row_column_name].present?
            comment  = '.'
            comment += "\rDescription: \"#{ qrc[:question_description] }\"" if qrc[:question_description].present?

            # Don't fetch question_row_column object from db unnecessarily.
            if qrc[:question_row_column_options].first.present?
              # Types with options are:
              #   (5) checkbox
              #   (6) dropdown
              #   (7) radio
              #   (8) select2-single
              #   (9) select2-multi
              if [5, 6, 7, 8, 9].include? QuestionRowColumn.find(qrc[:question_row_column_id]).question_row_column_type_id
                comment += "\rAnswer choices:"
                qrc[:question_row_column_options].each do |qrco|
                  comment += "\r    [Option ID: #{ qrco[0] }] #{ qrco[1] }"
                end  # qrc[:question_row_column_options].each do |qrco|
              end  # if [5, 6, 7, 8, 9].include? QuestionRowColumn.find(qrc[:question_row_column_id]).question_row_column_type_id
            end  # if qrc[:question_row_column_options].first.present?

            new_cell = header_row.add_cell "#{ title }\r[Question ID: #{ qrc[:question_id] }][Field ID: #{ qrc[:question_row_id] }x#{ qrc[:question_row_column_id] }]"
            sheet.add_comment ref: new_cell, author: 'Export AI', text: comment, visible: false if (qrc[:question_description].present? || qrc[:question_row_column_options].first.present?)
          end  # unless found
        end  # sheet_info.question_row_columns.each do |qrc|

        # Now we add the extraction rows.
        sheet_info.extractions.each do |key, extraction|
          eefps = efps.extractions_extraction_forms_projects_sections.find_or_create_by(
            extraction_id: extraction[:extraction_info][:extraction_id],
            extraction_forms_projects_section: efps)

          # If link_to_type1 is present we need to iterate each question for every type1 present in the extraction.
          eefpst1s = _fetch_eefpst1s(eefps)
          eefpst1s.each do |eefpst1|
            # If no kq is selected we should skip this row.
            next if extraction[:extraction_info][:kq_selection].blank?

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
            new_row << extraction[:extraction_info][:kq_selection]
            new_row << eefpst1.type1.name
            new_row << eefpst1.type1.description

            # Add question information.
            extraction[:question_row_columns].each do |qrc|
              if qrc[:eefpst1_id].eql?(eefpst1.id)

                # Try to find the column that matches the identifier.
                found, column_idx = nil
                found, column_idx = SheetInfo.find_column_idx_with_value(header_row, "[Question ID: #{ qrc[:question_id] }][Field ID: #{ qrc[:question_row_id] }x#{ qrc[:question_row_column_id] }]")

                # Something is wrong if it wasn't found.
                unless found
                  raise RuntimeError, "Error: Could not find header row: [Question ID: #{ qrc[:question_id] }][Field ID: #{ qrc[:question_row_id] }x#{ qrc[:question_row_column_id] }]"
                end

                new_row[column_idx] = qrc[:eefps_qrfc_values]
              end  # END if qrc[:type1_id].eql?(eefpst1.id)
            end  # END extraction[:question_row_columns].each do |qrc|

            sheet.add_row new_row
          end  # END eefpst1s.each do |eefpst1|
        end  # sheet_info.extractions.each do |key, extraction|

        # Re-apply the styling for the new cells in the header row before closing the sheet.
        sheet.column_widths 16, 16, 16, 50, 16, 16
        header_row.style = @highlight
      end  # END @package.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|

    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end

  #!!! Moved into sheet_info_modules.rb...we should remove this later.
  # Type2 (Questions) are associated to Key Questions and we export by the KQ's selected.
  def fetch_questions(kq_ids, efps)
    # Get all questions in this efps by key_questions requested.
    questions = efps.questions.joins(:key_questions_projects_questions)
      .where(
        key_questions_projects_questions: {
          key_questions_project: KeyQuestionsProject.where(project: @project, key_question_id: kq_ids)
        } )

    return questions.order(id: :asc).uniq
  end

  # Also make sure total is last in the list.
  def _fetch_eefpst1s(eefps)
    if (eefps.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1 and eefps.link_to_type1.present?)
      eefpst1s = eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.ordered.to_a

      _total_eefpst1 = eefpst1s.select { |eefpst1| eefpst1.type1_id.eql?(100) }
      eefpst1s_without_total = eefpst1s.delete_if { |eefpst1| eefpst1.type1_id.eql?(100) }
      eefpst1s = eefpst1s_without_total.concat(_total_eefpst1)

    else
      eefpst1s = [Struct.new(:id, :type1).new(nil, Struct.new(:id, :name, :description).new(nil))]

    end

    return eefpst1s
  end
end