require 'simple_export_job/sheet_info'

def build_type1_sections_compact(p, project, highlight, wrap)
  project.extraction_forms_projects.each do |ef|
    ef.extraction_forms_projects_sections.each do |section|

      # If this is a type1 section then we proceed.
      if section.extraction_forms_projects_section_type_id == 1

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ section.section.name.truncate(21) }" + ' - long') do |sheet|

          # Some prep work:
          last_col_idx  = 0
          header_row = sheet.add_row [
            'Extraction ID',
            'User Name',
            'Citation ID',
            'Citation Name',
            'RefMan',
            'PMID',
            "#{ section.section.name.singularize } Name",
            "#{ section.section.name.singularize } Description"
          ]

          # Every row represents an extraction.
          project.extractions.each do |extraction|
            eefps = section.extractions_extraction_forms_projects_sections.find_by(
              extraction: extraction,
              extraction_forms_projects_section: section
            )

            eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|

              new_row = []
              new_row << extraction.id.to_s
              new_row << extraction.user.profile.username
              new_row << extraction.citations_project.citation.id.to_s
              new_row << extraction.citations_project.citation.name
              new_row << extraction.citations_project.citation.refman.to_s
              new_row << extraction.citations_project.citation.pmid.to_s
              new_row << eefpst1.type1.name
              new_row << eefpst1.type1.description

              sheet.add_row new_row
            end  # END eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          end  # END project.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths nil, nil, nil, nil, nil, nil, nil, nil
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ section.section.name.truncate(21) }" + ' - compact') do |sheet|
      end  # END if section.extraction_forms_projects_section_type_id == 1
    end  # END ef.extraction_forms_projects_sections.each do |section|
  end  # END project.extraction_forms_projects.each do |ef|
end
