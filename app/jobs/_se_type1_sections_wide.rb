# We keep several dictionaries here. They all track the same information such as type1s, populations and timepoints.
# One list is kept as a master list. Those are on SheetInfo.type1s, SheetInfo.populations, and SheetInfo.timepoints.
# Another is kept for each extraction.
class SheetInfo
  attr_reader :header_info, :extractions, :type1s, :populations, :timepoints

  def initialize
    @header_info = ['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
    @extractions = Hash.new
    @type1s      = Set.new
    @populations = Set.new
    @timepoints  = Set.new
  end

  def new_extraction_info(extraction)
    @extractions[extraction.id] = {
      extraction_id: extraction.id,
      type1s: [],
      populations: [],
      timepoints: []
    }
  end

  def set_extraction_info(params)
    @extractions[params[:extraction_id]][:extraction_info] = params
  end

  def add_type1(params)
    @extractions[params[:extraction_id]][:type1s] << params
    params.delete(:extraction_id)
    @type1s << params
  end

  def add_population(params)
    @extractions[params[:extraction_id]][:populations] << params
    params.delete(:extraction_id)
    @populations << params
  end

  def add_timepoint(params)
    @extractions[params[:extraction_id]][:timepoints] << params
    params.delete(:extraction_id)
    @timepoints << params
  end
end

# Attempt to find the column index in the given row for a cell that starts with given value.
#
# returns (Boolean, Idx)
def _find_column_idx_with_value(row, value)
  row.cells.each do |cell|
    return [true, cell.index] if cell.value.start_with?(value)
  end

  return [false, row.cells.length]
end

def build_type1_sections_wide(p, project, highlight, wrap)
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a type1 section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 1

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name }" + ' - wide') do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # Every row represents an extraction.
          project.extractions.each do |extraction|
            # Create base for extraction information.
            sheet_info.new_extraction_info(extraction)

            # Collect basic information about the extraction.
            sheet_info.set_extraction_info(
              extraction_id: extraction.id,
              username: extraction.projects_users_role.projects_user.user.profile.username,
              citation_id: extraction.citations_project.citation.id,
              citation_name: extraction.citations_project.citation.name,
              refman: extraction.citations_project.citation.refman,
              pmid: extraction.citations_project.citation.pmid)

            eefps = efps.extractions_extraction_forms_projects_sections.find_by(extraction: extraction,
                                                                                extraction_forms_projects_section: efps)
            eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
              sheet_info.add_type1(
                extraction_id: extraction.id,
                id: eefpst1.type1.id,
                section_name: eefpst1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.section.name.singularize,
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

          header_row = sheet.add_row sheet_info.header_info

          # First build the complete header row.
          sheet_info.type1s.each do |type1|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[#{ type1[:section_name] } ID: #{ type1[:id] }]")

            # Append to the header if this is new.
            unless found
              header_row.add_cell "[#{ type1[:section_name] } ID: #{ type1[:id] }] Name"
              header_row.add_cell "[#{ type1[:section_name] } ID: #{ type1[:id] }] Description"
            end
          end  # sheet_info.type1s.each do |type1|

          sheet_info.populations.each do |pop|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[Population ID: #{ pop[:id] }]")

            # Append to the header if this is new.
            unless found
              header_row.add_cell "[Population ID: #{ pop[:id] }] Name"
              header_row.add_cell "[Population ID: #{ pop[:id] }] Description"
            end
          end  # sheet_info.populations].each do |pop|

          sheet_info.timepoints.each do |tp|
            # Try to find the column that matches the identifier.
            found, column_idx = nil
            found, column_idx = _find_column_idx_with_value(header_row, "[Timepoint ID: #{ tp[:id] }]")

            # Append to the header if this is new.
            unless found
              header_row.add_cell "[Timepoint ID: #{ tp[:id] }] Name"
              header_row.add_cell "[Timepoint ID: #{ tp[:id] }] Unit"
            end
          end  # sheet_info.timepoints.each do |tp|

          # Now we add the rows.
          sheet_info.extractions.each do |key, extraction|
            new_row = []
            new_row << extraction[:extraction_info][:extraction_id]
            new_row << extraction[:extraction_info][:username]
            new_row << extraction[:extraction_info][:citation_id]
            new_row << extraction[:extraction_info][:citation_name]
            new_row << extraction[:extraction_info][:refman]
            new_row << extraction[:extraction_info][:pmid]

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
                byebug
              end

              new_row[column_idx]     = type1[:name]
              new_row[column_idx + 1] = type1[:description]
            end  # extraction.type1s.each do |type1|

            extraction[:populations].each do |pop|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[Population ID: #{ pop[:id] }]")

              # Something is wrong if it wasn't found.
              unless found
                byebug
              end

              new_row[column_idx]     = pop[:name]
              new_row[column_idx + 1] = pop[:description]
            end  # extraction.populations.each do |population|

            extraction[:timepoints].each do |tp|
              # Try to find the column that matches the identifier.
              found, column_idx = nil
              found, column_idx = _find_column_idx_with_value(header_row, "[Timepoint ID: #{ tp[:id] }]")

              # Something is wrong if it wasn't found.
              unless found
                byebug
              end

              new_row[column_idx]     = tp[:name]
              new_row[column_idx + 1] = tp[:unit]
            end  # extraction.timepoints.each do |tp|

            # Done. Let's add the new row.
            sheet.add_row new_row
          end  # sheet_info.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths 14, 14, 13, 51, 15, 15, 24, 29, 24, 29, 24, 29, 24, 29, 24, 29, 24, 29, 24, 29
          header_row.style = highlight
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name }") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 1
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
