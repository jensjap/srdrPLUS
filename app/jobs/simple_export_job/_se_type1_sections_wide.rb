require 'simple_export_job/sheet_info'

def build_type1_sections_wide(p, project, highlight, wrap, kq_ids=[])
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a type1 section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 1

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # Every row represents an extraction.
          project.extractions.each do |extraction|
            # Collect distinct list of questions based off the key questions selected for this extraction.
            kq_ids_by_extraction = fetch_kq_selection(extraction, kq_ids)

            # Create base for extraction information.
            sheet_info.new_extraction_info(extraction)

            # Collect basic information about the extraction.
            sheet_info.set_extraction_info(
              extraction_id: extraction.id,
              username: extraction.projects_users_role.projects_user.user.profile.username,
              citation_id: extraction.citation.id,
              citation_name: extraction.citation.name,
              authors: extraction.citation.authors.collect(&:name).join(', '),
              publication_date: extraction.citation.try(:journal).try(:get_publication_year),
              refman: extraction.citation.refman,
              pmid: extraction.citation.pmid,
              kq_selection: KeyQuestion.where(id: kq_ids_by_extraction).collect(&:name).map(&:strip).join("\x0D\x0A"))

            eefps = efps.extractions_extraction_forms_projects_sections.find_or_create_by(
              extraction: extraction,
              extraction_forms_projects_section: efps)

            # Iterate over each of the type1s that are associated with this particular # extraction's
            # extraction_forms_projects_section and collect type1, population, and timepoint information.
            eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
              sheet_info.add_type1(
                extraction_id: extraction.id,
                section_name: efps.section.name.singularize,
                id: eefpst1.type1.id,
                name: eefpst1.type1.name,
                description: eefpst1.type1.description)
              eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |pop|
                sheet_info.add_population(
                  extraction_id: extraction.id,
                  id: pop.population_name.id,
                  name: pop.population_name.name,
                  description: pop.population_name.description)
                pop.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
                  sheet_info.add_timepoint(
                    extraction_id: extraction.id,
                    id: tp.timepoint_name.id,
                    name: tp.timepoint_name.name,
                    unit: tp.timepoint_name.unit)
                end  # pop.extractions_extraction_forms_projects_sections_type1_row_columns.each do |tp|
              end  # eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |pop|
            end  # eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          end  # END project.extractions.each do |extraction|

          # Start printing rows to the spreadsheet. First the basic headers:
          header_row = sheet.add_row sheet_info.header_info

          # Next continue the header row by adding all type1s together.
          sheet_info.type1s.each do |type1|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[#{ type1[:section_name] } ID: #{ type1[:id] }]")

            # Append to the header if this is new.
            unless found
              header_row.add_cell "Name\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
              header_row.add_cell "Description\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
            end
          end  # sheet_info.type1s.each do |type1|

          # Then all the populations together.
          sheet_info.populations.each do |pop|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[Population ID: #{ pop[:id] }]")

            # Append to the header if this is new.
            unless found
              header_row.add_cell "Name\r[Population ID: #{ pop[:id] }]"
              header_row.add_cell "Description\r[Population ID: #{ pop[:id] }]"
            end
          end  # sheet_info.populations].each do |pop|

          # And finally all the timepoints together.
          sheet_info.timepoints.each do |tp|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[Timepoint ID: #{ tp[:id] }]")

            # Append to the header if this is new.
            unless found
              header_row.add_cell "Name\r[Timepoint ID: #{ tp[:id] }]"
              header_row.add_cell "Unit\r[Timepoint ID: #{ tp[:id] }]"
            end
          end  # sheet_info.timepoints.each do |tp|

          # Now we add the extraction rows.
          sheet_info.extractions.each do |key, extraction|
            new_row = []
            new_row << extraction[:extraction_info][:extraction_id]
            new_row << extraction[:extraction_info][:username]
            new_row << extraction[:extraction_info][:citation_id]
            new_row << extraction[:extraction_info][:citation_name]
            new_row << extraction[:extraction_info][:refman]
            new_row << extraction[:extraction_info][:pmid]
            new_row << extraction[:extraction_info][:authors]
            new_row << extraction[:extraction_info][:publication_date]
            new_row << extraction[:extraction_info][:kq_selection]

            # We choose the order of the columns we want to add here.
            # This is a bit arbitrary but we choose: type1s > populations > timepoints
            # I know this is repetitive, but trying to generalize is almost just as
            # verbose plus there might be many more fields to come.
            extraction[:type1s].each do |type1|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[#{ type1[:section_name] } ID: #{ type1[:id] }]")

              # Something is wrong if it wasn't found.
              unless found
                raise RuntimeError, "Error: Could not find header row: [#{ type1[:section_name] } ID: #{ type1[:id] }]"
              end

              new_row[column_idx]     = type1[:name]
              new_row[column_idx + 1] = type1[:description]
            end  # extraction[:type1s].each do |type1|

            extraction[:populations].each do |pop|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[Population ID: #{ pop[:id] }]")

              # Something is wrong if it wasn't found.
              unless found
                raise RuntimeError, "Error: Could not find header row: [#{ type1[:section_name] } ID: #{ type1[:id] }]"
              end

              new_row[column_idx]     = pop[:name]
              new_row[column_idx + 1] = pop[:description]
            end  # extraction[:populations].each do |pop|

            extraction[:timepoints].each do |tp|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[Timepoint ID: #{ tp[:id] }]")

              # Something is wrong if it wasn't found.
              unless found
                raise RuntimeError, "Error: Could not find header row: [#{ type1[:section_name] } ID: #{ type1[:id] }]"
              end

              new_row[column_idx]     = tp[:name]
              new_row[column_idx + 1] = tp[:unit]
            end  # extraction[:timepoints].each do |tp|

            # Done. Let's add the new row.
            sheet.add_row new_row
          end  # sheet_info.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths 16, 16, 16, 50, 16, 16
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 1
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
