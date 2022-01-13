require 'simple_export_job/sheet_info'

def build_type1_sections_wide(kq_ids=[])
  @project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a type1 section then we proceed.
      next unless efps.extraction_forms_projects_section_type_id == 1

      # Add a new sheet.
      sheet_name = efps.section.name.truncate(24)
      @p.workbook.add_worksheet(name: ensure_unique_sheet_name(sheet_name)) do |sheet|

        # For each sheet we create a SheetInfo object.
        sheet_info = SheetInfo.new
        sheet_info.populate!(:type1, kq_ids, efp, efps)

        # Start printing rows to the spreadsheet. First the basic headers:
        header_row = sheet.add_row sheet_info.header_info

        # Next continue the header row by adding all type1s together.
        sheet_info.type1s.each do |type1|
          # Try to find the column that matches the identifier.
          found, column_idx = nil
          found, column_idx = _find_column_idx_with_value(header_row, "[#{ type1[:section_name] } ID: #{ type1[:id] }]")

          # Append to the header if this is new.
          unless found
            if sheet_name.eql?("Outcomes")
              header_row.add_cell "Domain\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
              header_row.add_cell "Specific Measurement\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
              header_row.add_cell "Units\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
            else
              header_row.add_cell "Name\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
              header_row.add_cell "Description\r[#{ type1[:section_name] } ID: #{ type1[:id] }]"
            end
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
          new_row << extraction[:extraction_info][:consolidated]
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
            new_row[column_idx + 2] = type1[:units] if sheet_name.eql?("Outcomes")
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
        header_row.style = @highlight
      end  # END @p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(24) }") do |sheet|

    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END @project.extraction_forms_projects.each do |efp|
end

def fill_sheet_info(sheet_info)

end