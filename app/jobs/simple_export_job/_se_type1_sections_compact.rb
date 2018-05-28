def build_type1_sections_compact(p, project, highlight, wrap)
  project.extraction_forms_projects.each do |ef|
    ef.extraction_forms_projects_sections.each do |section|

      # If this is a type1 section then we proceed.
      if section.extraction_forms_projects_section_type_id == 1

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ section.section.name.truncate(21) }" + ' - compact') do |sheet|

          # Some prep work:
          last_col_idx  = 0
          header_row = sheet.add_row ['Extraction ID', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']

          # Every row represents an extraction.
          project.extractions.each do |extraction|
            eefps = section.extractions_extraction_forms_projects_sections.find_by(extraction: extraction, extraction_forms_projects_section: section)

            new_row = []
            new_row << extraction.id.to_s
            new_row << extraction.citations_project.citation.id.to_s
            new_row << extraction.citations_project.citation.name
            new_row << extraction.citations_project.citation.refman.to_s
            new_row << extraction.citations_project.citation.pmid.to_s
            eefps.extractions_extraction_forms_projects_sections_type1s.each do |type1|
              for i in 1..eefps.extractions_extraction_forms_projects_sections_type1s.length
                if (i * 2) > last_col_idx
                  header_row.add_cell("#{ section.section.name } Name: #{ i.to_s }")
                  header_row.add_cell("#{ section.section.name } Description: #{ i.to_s }")

                  last_col_idx += 2
                end
              end
              new_row.concat [type1.type1.name, type1.type1.description]
            end

            sheet.add_row new_row
          end  # END project.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ section.section.name.truncate(21) }" + ' - compact') do |sheet|
      end  # END if section.extraction_forms_projects_section_type_id == 1
    end  # END ef.extraction_forms_projects_sections.each do |section|
  end  # END project.extraction_forms_projects.each do |ef|
end
