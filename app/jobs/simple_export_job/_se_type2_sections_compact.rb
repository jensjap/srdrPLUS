require 'simple_export_job/sheet_info'

COL_CNT_WITHOUT_LINK_TO_TYPE1 = 10
COL_CNT_WITH_LINK_TO_TYPE1    = 12

def build_type2_sections_compact(p, project, highlight, wrap, kq_ids=[], print_empty_row=false)




  # The main extraction form is always the first efp.
  efp = project.extraction_forms_projects.first
  efp.extraction_forms_projects_sections.each do |efps|

    # If this is a type2 section then we proceed.
    if efps.extraction_forms_projects_section_type_id == 2

      # Add a new sheet.
      p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(21) } - long") do |sheet|

        # For each sheet we create a SheetInfo object.
        sheet_info = SheetInfo.new

        # First the basic headers:
        header_elements = sheet_info.header_info
        header_elements = header_elements.concat(['Key Questions'])

        # Add additional column headers to capture the link_to_type1 name and description
        # if link_to_type1 is present and add to header_elements.
        if efps.link_to_type1
          header_elements = header_elements.concat [
            "#{ efps.link_to_type1.section.name.singularize } Name",
            "#{ efps.link_to_type1.section.name.singularize } Description"
          ]
        end

        # Add question text and instruction column headers to header_elements.
        header_elements.concat ['Question Text']

        # Instantiate proper header Axlsx::Row element.
        header_row = sheet.add_row header_elements

        # Collect distinct list of questions.
        questions = fetch_questions(project, kq_ids, efps)

        # Iterate over each extraction in the project.
        project.extractions.each do |extraction|
          eefps = efps.extractions_extraction_forms_projects_sections.find_by(
            extraction: extraction,
            extraction_forms_projects_section: efps
          )

          # If link_to_type1 is present we need to iterate each question for every type1 present in the extraction.
          if efps.link_to_type1.present?
            eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
              questions.each do |question|
                new_row = [
                  extraction.id,
                  extraction.user.profile.username,
                  extraction.citation.id,
                  extraction.citation.name,
                  extraction.citation.refman,
                  extraction.citation.pmid,
                  extraction.citation.authors.collect(&:name).join(', '),
                  extraction.citation.try(:journal).try(:publication_date).to_s,
                  question.key_questions_projects_questions.collect(&:key_questions_project).collect(&:key_question).collect(&:name).join(', ').to_s,
                  eefpst1.type1.name,
                  eefpst1.type1.description,
                  question.name
                ]

                has_values, qrc_components = build_qrc_components_for_question(eefps, eefpst1.id, question)
                new_row = new_row.concat(qrc_components)

                if (has_values || print_empty_row)
                  # Add row to the sheet.
                  sheet.add_row new_row
                  # Adjust column headers for each qrc component.
                  adjust_header_row_to_account_for_qrc_components(header_row, new_row, true)
                end  # END if has_values
              end  # END questions.each do |question|
            end  # END eefps.link_to_type1.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|

          # If no link is present we only need it once and use eefpst1 with value nil.
          else
            eefpst1 = nil
            questions.each do |question|
              new_row = [
                extraction.id,
                extraction.user.profile.username,
                extraction.citation.id,
                extraction.citation.name,
                extraction.citation.refman,
                extraction.citation.pmid,
                extraction.citation.authors.collect(&:name).join(', '),
                extraction.citation.try(:journal).try(:publication_date).to_s,
                question.key_questions_projects_questions.collect(&:key_questions_project).collect(&:key_question).collect(&:name).join(', ').to_s,
                question.name
              ]

              has_values, qrc_components = build_qrc_components_for_question(eefps, eefpst1, question)
              new_row = new_row.concat(qrc_components)

              if (has_values || print_empty_row)
                # Add row to the sheet.
                sheet.add_row new_row
                # Adjust column headers for each qrc component.
                adjust_header_row_to_account_for_qrc_components(header_row, new_row, false)
              end  # END if has_values
            end  # END questions.each do |question|
          end  # END if efps.link_to_type1.present?
        end  # END project.extractions.each do |extraction|

        # Re-apply the styling for the new cells in the header row before closing the sheet.
        sheet.column_widths nil
        header_row.style = highlight
      end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(21) } - long") do |sheet|
    end  # END if efps.extraction_forms_projects_section_type_id == 2
  end  # END efp.extraction_forms_projects_sections.each do |efps|
end

# Type2 (Questions) are associated to Key Questions and we export by the KQ's selected.
# If no KQ's array is passed in, we assume to export all.
def fetch_questions(project, kq_ids, efps)
  # Get all questions in this efps by key_questions requested.
  if kq_ids.present?
    questions = efps.questions.joins(:key_questions_projects_questions)
      .where(
        key_questions_projects_questions: {
          key_questions_project: KeyQuestionsProject.where(project: project, key_question_id: kq_ids)
        } )
  else
    questions = efps.questions.joins(:key_questions_projects_questions)
      .where(
        key_questions_projects_questions: {
          key_questions_project: KeyQuestionsProject.where(project: project)
        } )
  end

  return questions.distinct.order(id: :asc)
end

def build_qrc_components_for_question(eefps, eefpst1_id, question)
  qrc_components = []
  has_values = false

  question.question_rows.each_with_index do |qr, row_idx|
    qr.question_row_columns.each_with_index do |qrc, col_idx|

      value = eefps.eefps_qrfc_values(eefpst1_id, qrc)
      has_values = value.present? unless has_values.present?

      if (qr.name.present? && qrc.name.present?)
        qrc_components = qrc_components.concat [
          "[#{ qr.name }] x [#{ qrc.name }]",
          value
        ]
      elsif (qr.name.present? && qrc.name.blank?)
        qrc_components = qrc_components.concat [
          "[#{ qr.name }]",
          value
        ]
      elsif (qr.name.blank? && qrc.name.present?)
        qrc_components = qrc_components.concat [
          "[#{ qrc.name }]",
          value
        ]
      else
        qrc_components = qrc_components.concat [
          "",
          value
        ]
      end

    end  # END qr.question_row_columns.each_with_index do |qrc, col_idx|
  end  # END question.question_rows.each_with_index do |qr, row_idx|

  return has_values, qrc_components
end

def adjust_header_row_to_account_for_qrc_components(header_row, new_row, link_to_type1_present)
  if link_to_type1_present
    for i in COL_CNT_WITH_LINK_TO_TYPE1..new_row.length-1
      set_qrc_column_header(header_row, i)
    end  # END for i in COL_CNT_WITH_LINK_TO_TYPE1..new_row.length-1

  else
    for i in COL_CNT_WITHOUT_LINK_TO_TYPE1..new_row.length-1
      set_qrc_column_header(header_row, i)
    end

  end  # END if link_to_type1_present
end

def set_qrc_column_header(header_row, i)
  begin
    header_row[i].value
  rescue Exception => e
    if i.even?
      header_row.add_cell 'Cell Descriptor'
    else
      header_row.add_cell 'Value'
    end  # END if i.even?
  end  # END begin
end
