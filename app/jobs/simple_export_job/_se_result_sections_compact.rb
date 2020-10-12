require 'simple_export_job/sheet_info'




def build_result_sections_compact(p, project, highlight, wrap)
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a results section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 3

        # Add a new sheet.
        p.workbook.add_worksheet(name: "#{ efps.section.name.truncate(21) } - compact") do |sheet|

          # For each sheet we create a SheetInfo object.
          sheet_info = SheetInfo.new

          # First the basic headers:
          # ['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
          header_elements = sheet_info.header_info

















          # Every row represents an extraction.
          project.extractions.each do |extraction|
            eefps = efps.extractions_extraction_forms_projects_sections.find_by(extraction: extraction, extraction_forms_projects_section: efps)
          end  # project.extractions.each do |extraction|
        end  # END p.workbook.add_worksheet(name: "#{ efps.section.name }") do |sheet|
      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
