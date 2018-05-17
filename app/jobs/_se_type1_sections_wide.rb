# Attempt to find the type1 ID in the column row.
#
# returns (Boolean, Idx)
def _find_column_idx_with_value(row, value)
  row.cells.each do |cell|
    return [true, cell.index] if cell.value.start_with?("[ID: #{ value }]")
  end

  return [false, row.cells.length]
end

def build_type1_sections_wide(p, project, highlight, wrap)
  project.extraction_forms_projects.each do |ef|
    ef.extraction_forms_projects_sections.each do |section|

      # If this is a type1 section then we proceed.
      if section.extraction_forms_projects_section_type_id == 1

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ section.section.name }" + ' - wide') do |sheet|

          # Some prep work:
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
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, type1.type1.id.to_s)

              # We need to append to the header.
              unless found
                header_row.add_cell "[ID: #{ type1.type1.id.to_s }] #{ section.section.name.singularize } Name"
                header_row.add_cell "[ID: #{ type1.type1.id.to_s }] #{ section.section.name.singularize } Description"
              end

              new_row[column_idx]     = type1.type1.name
              new_row[column_idx + 1] = type1.type1.description
            end

            sheet.add_row new_row
          end  # END project.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ section.section.name }") do |sheet|
      end  # END if section.extraction_forms_projects_section_type_id == 1
    end  # END ef.extraction_forms_projects_sections.each do |section|
  end  # END project.extraction_forms_projects.each do |ef|
end
