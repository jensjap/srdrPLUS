class SimpleExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    @project = Project.find(args.first)
    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"

    Axlsx::Package.new do |p|
      p.use_shared_strings = true
      wrap      = p.workbook.styles.add_style alignment: { wrap_text: true }
      highlight = p.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)'

      # Sheet with basic project information.
      p.workbook.add_worksheet(name: 'Project Information') do |sheet|
        sheet.add_row ['Project Information:'],                                      style: highlight
        sheet.add_row ['Name',                    @project.name]
        sheet.add_row ['Description',             @project.description],             style: wrap
        sheet.add_row ['Attribution',             @project.attribution],             style: wrap
        sheet.add_row ['Methodology Description', @project.methodology_description], style: wrap
        sheet.add_row ['Prospero',                @project.prospero]
        #!!! Not sure why this is creating a problem.
        #sheet.add_row ['DOI',                     @project.doi]
        sheet.add_row ['Notes',                   @project.notes],                   style: wrap
        sheet.add_row ['Funding Source',          @project.funding_source]

        # Project member list.
        sheet.add_row ['Project Member List:'],                                      style: highlight
        sheet.add_row ['Username', 'First Name', 'Middle Name', 'Last Name', 'Email']
        @project.members.each do |member|
          sheet.add_row [member.profile.username, member.profile.first_name, member.profile.middle_name, member.profile.last_name, member.email]
        end
      end

      # Type 1s.
      @project.extraction_forms_projects.each do |ef|
        ef.extraction_forms_projects_sections.each do |section|
          if section.extraction_forms_projects_section_type_id == 1
            @project.extractions.each do |extraction|
              eefps = section.extractions_extraction_forms_projects_sections.find_by(extraction: extraction, extraction_forms_projects_section: section)
              p.workbook.add_worksheet(name: "#{ section.section.name }") do |sheet|
                #sheet.add_row ['Name', 'Description', 'Units'], style: highlight
                #eefps.extractions_extraction_forms_projects_sections_type1s.each do |type1|
                #  sheet.add_row [type1.type1.name, type1.type1.description, type1.units]
                #end

                # Some prep work:
                new_row = []
                last_col_idx  = 0
                section_name  = eefps.section.name

                header_row = sheet.add_row ['Citation ID', 'Citation Name', 'RefMan', 'PMID']
                new_row << extraction.citations_project.id.to_s
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

                header_row.style = highlight
                sheet.add_row new_row
              end
            end
          end
        end
      end

      # Default sample 3D pie chart.
      p.workbook.add_worksheet(:name => "Pie Chart") do |sheet|
        sheet.add_row ["Simple Pie Chart"]
        %w(first second third).each { |label| sheet.add_row [label, rand(24)+1] }
        sheet.add_chart(Axlsx::Pie3DChart, :start_at => [0,5], :end_at => [10, 20], :title => "example 3: Pie Chart") do |chart|
          chart.add_series :data => sheet["B2:B4"], :labels => sheet["A2:A4"],  :colors => ['FF0000', '00FF00', '0000FF']
        end
      end
      p.serialize('simple.xlsx')
    end
  end
end
