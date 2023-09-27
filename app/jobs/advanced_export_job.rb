class AdvancedExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  rescue_from(StandardError) do |exception|
    Sentry.capture_exception(exception) if Rails.env.production?
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second).deliver_later
  end

  def perform(*args)
    Axlsx::Package.new do |package|
      @user_email = args.first
      @project = Project
                 .includes(
                   projects_users: { user: :profile, project: :extractions },
                   extraction_forms_projects: {
                     extraction_forms_projects_sections: [:section, {
                       extractions_extraction_forms_projects_sections: [:extraction, {
                         extractions_extraction_forms_projects_sections_type1s: :type1
                       }]
                     }]
                   }
                 )
                 .find(args.second)
      @export_type = args.third
      @package = package
      @package.use_shared_strings = true
      @package.use_autowidth = true
      @highlight = @package.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14,
                                                      font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      @wrap = @package.workbook.styles.add_style alignment: { wrap_text: true }

      @efp = @project.extraction_forms_projects.first
      all_sections = @efp.extraction_forms_projects_sections
      @type1_efpss = all_sections.select { |section| section.extraction_forms_projects_section_type_id == 1 }
      @type2_efpss = all_sections.select { |section| section.extraction_forms_projects_section_type_id == 2 }
      @result_efpss = all_sections.select { |section| section.extraction_forms_projects_section_type_id == 3 }
      @extractions = @project.extractions

      # Generate XLSX with basic project information.
      filename = generate_xlsx_and_filename
      raise 'Unable to serialize' unless @package.serialize(filename)
    end
    nil
  end

  def default_headers
    ['Extraction ID', 'Consolidated', 'Username', 'Citation ID', 'Citation Name', 'RefMan',
     'other_reference', 'PMID', 'Authors', 'Publication Date', 'Key Questions']
  end

  def generate_xlsx_and_filename
    add_project_information_section
    add_type1_sections
    # add_type2_sections
    # add_results
    'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_advanced.xlsx'
  end

  def add_project_information_section
    # Sheet with basic project information.
    @package.workbook.add_worksheet(name: 'Project Information') do |sheet|
      sheet.add_row ['Project Information:'], style: [@highlight]
      sheet.add_row ['Name',                    @project.name]
      sheet.add_row ['Description',             @project.description], style: [@wrap]
      sheet.add_row ['Attribution',             @project.attribution]
      sheet.add_row ['Methodology Description', @project.methodology_description]
      sheet.add_row ['Prospero',                @project.prospero],                types: [nil, :string]
      sheet.add_row ['DOI',                     @project.doi],                     types: [nil, :string]
      sheet.add_row ['Notes',                   @project.notes]
      sheet.add_row ['Funding Source',          @project.funding_source]

      # Project member list.
      sheet.add_row ['Project Member List:'], style: [@highlight]
      sheet.add_row ['Username', 'First Name', 'Middle Name', 'Last Name', 'Email', 'Extraction ID']
      @project.projects_users.each do |projects_user|
        sheet.add_row [
          projects_user.user.profile.username,
          projects_user.user.profile.first_name,
          projects_user.user.profile.middle_name,
          projects_user.user.profile.last_name,
          projects_user.user.email,
          projects_user.project.extractions.select do |extraction|
            extraction.user_id == projects_user.user.id
          end.map(&:id)
        ]
      end

      # Re-apply the styling for the new cells before closing the sheet.
      sheet.column_widths nil
    end
  end

  def add_type1_sections
    type1_efpss_lookup = {}
    @type1_efpss.each do |efps|
      type1_efpss_lookup[efps.id] = {}
      lookup = {}
      type1s_order = []
      type1s_lookup = {}
      eefpss = efps.extractions_extraction_forms_projects_sections
      eefpss.each do |eefps|
        extraction = eefps.extraction
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          type1 = eefpst1.type1
          type1s_lookup[type1.id] = {
            record_type: 'Type1',
            id: type1.id,
            name: type1.name
          }
          type1s_order << type1.id unless type1s_order.include?(type1.id)
          lookup[extraction.id] ||= {}
          lookup[extraction.id][type1.id] ||= {
            record_type: 'Type1',
            id: type1.id,
            name: type1.name
          }
        end
      end
      type1_efpss_lookup[efps.id][:lookup] = lookup
      type1_efpss_lookup[efps.id][:type1s_order] = type1s_order
      type1_efpss_lookup[efps.id][:type1s_lookup] = type1s_lookup
    end
    @type1_efpss.each do |efps|
      @package.workbook.add_worksheet(name: efps.section.name) do |sheet|
        headers = default_headers
        headers += type1_efpss_lookup[efps.id][:type1s_order].map(&:to_s)
        headers += type1_efpss_lookup[efps.id][:type1s_order].map(&:to_s)
        sheet.add_row(headers)
      end
    end
  end

  def add_type2_sections
    efp = @project.extraction_forms_projects.first
    efp.extraction_forms_projects_sections.each do |efps|
      next unless efps.extraction_forms_projects_section_type_id == 2

      @package.workbook.add_worksheet(name: efps.section.name) do |sheet|
      end
    end
  end

  def add_results
    efp = @project.extraction_forms_projects.first
    efp.extraction_forms_projects_sections.each do |efps|
      next unless efps.extraction_forms_projects_section_type_id == 3

      @package.workbook.add_worksheet(name: efps.section.name) do |sheet|
      end
    end
  end
end
