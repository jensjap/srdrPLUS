module SimpleExportJob::SectionTemplates::Type1SectionsCompact
  def build_type1_sections_compact(kq_ids = [])
    @project.extraction_forms_projects.each do |ef|
      ef.extraction_forms_projects_sections.each do |section|
        # If this is a type1 section then we proceed.
        next unless section.extraction_forms_projects_section_type_id == 1

        # Add a new sheet.
        @package.workbook.add_worksheet(name: ensure_unique_sheet_name(section.section.name.try(:truncate,
                                                                                                21))) do |sheet|
          # For each sheet we create a SheetInfo object.
          sheet_info = SimpleExportJob::SheetInfo.new(@project)

          # Build header row.
          header_elements = sheet_info.header_info
          header_elements = header_elements.concat([
                                                     "#{section.section.name.try(:singularize)} Name",
                                                     "#{section.section.name.try(:singularize)} Description"
                                                   ])
          header_row = sheet.add_row header_elements

          # Every row represents an extraction.
          @project.extractions.each do |extraction|
            # Collect distinct list of questions based off the key questions selected for this extraction.
            kq_ids_by_extraction = SimpleExportJob::SheetInfo.fetch_kq_selection(extraction, kq_ids)

            eefps = section.extractions_extraction_forms_projects_sections.find_by(
              extraction:,
              extraction_forms_projects_section: section
            )

            eefps.try(:extractions_extraction_forms_projects_sections_type1s).try(:each) do |eefpst1|
              new_row = []
              new_row << extraction.id.to_s
              new_row << extraction.consolidated.to_s
              new_row << extraction.username
              new_row << extraction.citations_project.citation.id.to_s
              new_row << extraction.citations_project.citation.name
              new_row << extraction.citations_project.citations_project.refman.to_s
              new_row << extraction.citations_project.citations_project.other_reference.to_s
              new_row << extraction.citations_project.citation.pmid.to_s
              new_row << extraction.citations_project.citation.authors
              new_row << extraction.citations_project.citation.try(:journal).try(:get_publication_year)
              new_row << KeyQuestion.where(id: kq_ids_by_extraction).collect(&:name).map(&:strip).join("\x0D\x0A")
              new_row << eefpst1.type1.name
              new_row << eefpst1.type1.description

              sheet.add_row new_row
            end # END eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          end # END @project.extractions.each do |extraction|

          # Re-apply the styling for the new cells in the header row before closing the sheet.
          sheet.column_widths nil, nil, nil, nil, nil, nil, nil, nil
          header_row.style = @highlight
        end # END @package.workbook.add_worksheet(name: "#{ section.section.name.truncate(21) }") do |sheet|
      end # END ef.extraction_forms_projects_sections.each do |section|
    end  # END @project.extraction_forms_projects.each do |ef|
  end
end
