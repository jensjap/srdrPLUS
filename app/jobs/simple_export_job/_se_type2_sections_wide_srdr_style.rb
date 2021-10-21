require 'simple_export_job/sheet_info'

def build_type2_sections_wide_srdr_style(kq_ids=[], print_empty_row=false)

  # The main extraction form is always the first efp.
  efp = @project.extraction_forms_projects.first
  efp.extraction_forms_projects_sections.each do |efps|

    # If this is a type2 section then we proceed.
    next unless efps.extraction_forms_projects_section_type_id == 2

    # Add a new sheet.
    @p.workbook.add_worksheet(name: ensure_unique_sheet_name(efps.section.name.try(:truncate, 24))) do |sheet|

      # For each sheet we create a SheetInfo object.
      sheet_info = SheetInfo.new

      # Every row represents an extraction.
      @project.extractions.each do |extraction|
        # Create base for extraction information.
        sheet_info.new_extraction_info(extraction)

        # Collect distinct list of questions based off the key questions selected for this extraction.
        kq_ids_by_extraction = fetch_kq_selection(extraction, kq_ids)
        questions = fetch_questions(kq_ids_by_extraction, efps)

        # Collect basic information about the extraction.
        sheet_info.set_extraction_info(
          extraction_id: extraction.id,
          consolidated: extraction.consolidated.to_s,
          username: extraction.username,
          citation_id: extraction.citation.id,
          citation_name: extraction.citation.name,
          authors: extraction.citation.authors.collect(&:name).join(', '),
          publication_date: extraction.citation.try(:journal).try(:get_publication_year),
          refman: extraction.citation.refman,
          pmid: extraction.citation.pmid,
          kq_selection: KeyQuestion.where(id: kq_ids_by_extraction).collect(&:name).map(&:strip).join("\x0D\x0A"))

        eefps = efps.extractions_extraction_forms_projects_sections.find_or_create_by!(
          extraction: extraction,
          link_to_type1: efps.link_to_type1.nil? ?
            nil :
            ExtractionsExtractionFormsProjectsSection.find_or_create_by!(
              extraction: extraction,
              extraction_forms_projects_section: efps.link_to_type1
            )
        )

        # If this section is linked we have to iterate through each occurrence of
        # type1 via eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.
        # Otherwise we proceed with eefpst1s set to a custom Struct that responds
        # to :id, type1: :id.
        eefpst1s = (eefps.extraction_forms_projects_section.try(:extraction_forms_projects_section_option).try(:by_type1) &&
          eefps.link_to_type1.present?) ?
            eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s :
            [Struct.new(:id, :type1).new(nil, Struct.new(:id, :name, :description).new(nil))]

        eefpst1s.each do |eefpst1|
          questions.each do |q|
            q.question_rows.each do |qr|
              qr.question_row_columns.each do |qrc|
                sheet_info.add_question_row_column(
                  extraction_id: extraction.id,
                  section_name: efps.section.name.try(:singularize),
                  eefpst1_id: eefpst1.id,
                  type1_id: eefpst1.type1.id,
                  type1_name: eefpst1.type1.name,
                  type1_description: eefpst1.type1.description,
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
      end  # @project.extractions.each do |extraction|

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
        found, column_idx = _find_column_idx_with_value(header_row,
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
              found, column_idx = _find_column_idx_with_value(header_row, "[Question ID: #{ qrc[:question_id] }][Field ID: #{ qrc[:question_row_id] }x#{ qrc[:question_row_column_id] }]")

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
    end  # END @p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|

  end  # END efp.extraction_forms_projects_sections.each do |efps|
end

# Type2 (Questions) are associated to Key Questions and we export by the KQ's selected.
def fetch_questions(kq_ids, efps)
  # Get all questions in this efps by key_questions requested.
  questions = efps.questions.joins(:key_questions_projects_questions)
    .where(
      key_questions_projects_questions: {
        key_questions_project: KeyQuestionsProject.where(project: @project, key_question_id: kq_ids)
      } )

  return questions.distinct.order(id: :asc)
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
