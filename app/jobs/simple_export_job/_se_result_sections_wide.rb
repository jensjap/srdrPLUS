require 'simple_export_job/sheet_info'

def build_result_sections_wide(p, project, highlight, wrap, kq_ids=[])
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a result section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 3

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # Every row represents an extraction.
          populate_sheet_info_with_extractions_results_data(sheet_info, project, kq_ids, efp, efps)

          # Start printing rows to the spreadsheet. First the basic headers:
          #['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
          header_row = sheet.add_row sheet_info.header_info

          # Next continue the header row by adding all rssms together.
          sheet_info.rssms.each do |rssm|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row,
              "[Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_type_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]")

            # Append to the header if this is new.
            unless found
              title  = ''
              title += "#{ Type1.find(rssm[:outcome_id]).short_name_and_description } - " unless rssm[:outcome_id].blank?
              title += "#{ rssm[:population_name] }"
              title += " - #{ rssm[:result_statistic_section_type_name] }"
              case rssm[:result_statistic_section_type_name]
              when 'Descriptive Statistics'
                title += " - #{ TimepointName.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Type1.find(rssm[:col_id]).pretty_print_export_header }"
              when 'Between Arm Comparisons'
                title += " - #{ TimepointName.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Comparison.find(rssm[:col_id]).pretty_print_export_header }"
              when 'Within Arm Comparisons'
                title += " - #{ Comparison.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Type1.find(rssm[:col_id]).pretty_print_export_header }"
              when 'NET Change'
                title += " - #{ Comparison.find(rssm[:row_id]).pretty_print_export_header }"
                title += " - #{ Comparison.find(rssm[:col_id]).pretty_print_export_header }"
              end
              title += " - #{ rssm[:measure_name] }"
#              comment  = '.'
#              comment += "\rDescription: \"#{ qrc[:question_description] }\"" if qrc[:question_description].present?
#              comment += "\rAnswer choices: #{ qrc[:question_row_column_options] }" if qrc[:question_row_column_options].first.present?
              new_cell = header_row.add_cell "#{ title }\r[Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_type_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]"
#              sheet.add_comment ref: new_cell, author: 'Export AI', text: comment, visible: false if (qrc[:question_description].present? || qrc[:question_row_column_options].first.present?)
            end  # unless found
          end  # sheet_info.rssms.each do |rssm|

          # Now we add the extraction rows.
          sheet_info.extractions.each do |key, extraction|
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

            # Add question information.
            extraction[:rssms].each do |rssm|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row,
                "[Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_type_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]")

              # Something is wrong if it wasn't found.
              unless found
                raise RuntimeError, "Error: Could not find header row: [Outcome ID: #{ rssm[:outcome_id] }][Population ID: #{ rssm[:population_id] }][RSS Type ID: #{ rssm[:result_statistic_section_type_id] }][Row ID: #{ rssm[:row_id] }][Col ID: #{ rssm[:col_id] }][Measure ID: #{ rssm[:measure_id] }]"
              end

              new_row[column_idx] = rssm[:rssm_values]
            end  # extraction[:questions].each do |q|

            # Done. Let's add the new row.
            sheet.add_row new_row
          end  # sheet_info.extractions.each do |key, extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths 16, 16, 16, 50, 16, 16
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
