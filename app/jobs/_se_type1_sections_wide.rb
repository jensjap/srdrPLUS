# Attempt to find the type1 ID in the column row.
#
# returns (Boolean, Idx)
def _find_column_idx_with_value(row, value)
  row.cells.each do |cell|
    return [true, cell.index] if cell.value.start_with?(value)
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
          header_row = sheet.add_row ['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']

          # Every row represents an extraction.
          project.extractions.each do |extraction|
            eefps = section.extractions_extraction_forms_projects_sections.find_by(extraction: extraction, extraction_forms_projects_section: section)

            new_row = []
            new_row << extraction.id.to_s
            new_row << extraction.projects_users_role.projects_user.user.profile.username
            new_row << extraction.citations_project.citation.id.to_s
            new_row << extraction.citations_project.citation.name
            new_row << extraction.citations_project.citation.refman.to_s
            new_row << extraction.citations_project.citation.pmid.to_s

            # Add type1 and description first.
            eefps.extractions_extraction_forms_projects_sections_type1s.each do |type1|
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[#{ section.section.name.singularize } ID: #{ type1.type1.id.to_s }]")

              # Append to the header if this is new.
              unless found
                header_row.add_cell "[#{ section.section.name.singularize } ID: #{ type1.type1.id.to_s }] #{ section.section.name.singularize } Name"
                header_row.add_cell "[#{ section.section.name.singularize } ID: #{ type1.type1.id.to_s }] #{ section.section.name.singularize } Description"
              end

              new_row[column_idx]     = type1.type1.name
              new_row[column_idx + 1] = type1.type1.description
            end

            # Add population and time points if necessary.
            eefps.extractions_extraction_forms_projects_sections_type1s.each do |type1|
              type1.extractions_extraction_forms_projects_sections_type1_rows.each do |timepoint|
                timepoint.extractions_extraction_forms_projects_sections_type1_row_columns.each do |population|
                  found, column_idx = nil
                  found, column_idx = _find_column_idx_with_value(header_row, "[Population ID: #{ population.id.to_s }]")

                  # Append to the header if this is new.
                  unless found
                    header_row.add_cell "[Population ID: #{ population.id.to_s }] Population Name"
                    header_row.add_cell "[Population ID: #{ population.id.to_s }] Population Description"
                  end

                  new_row[column_idx]     = population.name
                  new_row[column_idx + 1] = population.description
                end
              end
            end

            sheet.add_row new_row
          end  # END project.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths 14, 14, 13, 51, 15, 15, 24, 29, 24, 29, 24, 29, 24, 29, 24, 29, 24, 29, 24, 29
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ section.section.name }") do |sheet|
      end  # END if section.extraction_forms_projects_section_type_id == 1
    end  # END ef.extraction_forms_projects_sections.each do |section|
  end  # END project.extraction_forms_projects.each do |ef|
end
