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
      @project =
        Project
        .includes(
          projects_users: { user: :profile, project: :extractions },
          extraction_forms_projects: {
            extraction_forms_projects_sections: [:section, {
              extractions_extraction_forms_projects_sections: {
                extraction: {
                  citations_project: { citation: :journal },
                  user: :profile,
                  extractions_key_questions_projects_selections: {
                    key_questions_project: :key_question
                  }
                },
                extractions_extraction_forms_projects_sections_type1s: :type1
              }
            }]
          }
        )
        .find(args.second)
      @export_type = args.third
      @package = package
      @package.use_shared_strings = true
      @package.use_autowidth = true
      @highlight = @package.workbook.styles.add_style(
        bg_color: 'C7EECF', fg_color: '09600B', sz: 14,
        font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      )
      @wrap = @package.workbook.styles.add_style(alignment: { wrap_text: true })

      @efp = @project.extraction_forms_projects.first
      efpss = @efp.extraction_forms_projects_sections
      @type1_efpss = efpss.select { |section| section.extraction_forms_projects_section_type_id == 1 }
      @type2_efpss = efpss.select { |section| section.extraction_forms_projects_section_type_id == 2 }
      @result_efpss = efpss.select { |section| section.extraction_forms_projects_section_type_id == 3 }
      @extractions = @project.extractions

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
    @package.workbook.add_worksheet(name: 'Project Information') do |sheet|
      sheet.add_row(['Project Information:'], style: [@highlight])
      sheet.add_row(['Name', @project.name])
      sheet.add_row(['Description', @project.description], style: [@wrap])
      sheet.add_row(['Attribution', @project.attribution])
      sheet.add_row(['Methodology Description', @project.methodology_description])
      sheet.add_row(['Prospero', @project.prospero], types: [nil, :string])
      sheet.add_row(['DOI', @project.doi], types: [nil, :string])
      sheet.add_row(['Notes', @project.notes])
      sheet.add_row(['Funding Source', @project.funding_source])
      sheet.add_row(['Project Member List:'], style: [@highlight])
      sheet.add_row(['Username', 'First Name', 'Middle Name', 'Last Name', 'Email', 'Extraction ID'])
      @project.projects_users.each do |projects_user|
        sheet.add_row(
          [
            projects_user.user.profile.username,
            projects_user.user.profile.first_name,
            projects_user.user.profile.middle_name,
            projects_user.user.profile.last_name,
            projects_user.user.email,
            projects_user.project.extractions.select do |extraction|
              extraction.user_id == projects_user.user.id
            end.map(&:id)
          ]
        )
      end
    end
  end

  def add_type1_sections
    type1_efpss_lookup = {}
    global_type1s_lookup = {}
    @type1_efpss.each do |efps|
      section_name = efps.section.name
      type1s = []
      type1s_lookups = {}
      extractions = []
      extractions_lookups = {}
      units_lookup = {}
      eefpss = efps.extractions_extraction_forms_projects_sections
      eefpss.each do |eefps|
        extractions << eefps.extraction unless extractions.include?(eefps.extraction)
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          type1 = eefpst1.type1
          type1s << type1 unless type1s.include?(type1)
          type1s_lookups[type1.id] ||= {
            name: type1.name,
            description: type1.description
          }
          units_lookup["#{eefps.extraction.id}-#{type1.id}"] = eefpst1.units
          extractions_lookups[eefps.extraction.id] ||= {}
          extractions_lookups[eefps.extraction.id][type1.id] = true
        end
      end
      @package.workbook.add_worksheet(name: section_name) do |sheet|
        headers = default_headers
        type1s.each do |type1|
          header_multiplier = section_name == 'Outcomes' ? 3 : 2
          headers += (["#{efps.section.name} ID: #{type1.id}"] * header_multiplier)
        end
        sheet.add_row(headers)
        extractions.each do |extraction|
          row = [
            extraction.id,
            extraction.consolidated,
            extraction.user.profile.username,
            extraction.citations_project.citation.id,
            extraction.citations_project.citation.name,
            extraction.citations_project.citation.refman,
            extraction.citations_project.citation.other,
            extraction.citations_project.citation.pmid,
            extraction.citations_project.citation.authors,
            extraction.citations_project.citation.year,
            extraction.extractions_key_questions_projects_selections.map do |ekqps|
              ekqps.key_questions_project.key_question.name
            end.join("\x0D\x0A")
          ]
          type1s.each do |type1|
            type_hash = type1s_lookups[type1.id]
            if extractions_lookups.try(:[], extraction.id).try(:[], type1.id)
              row << type_hash[:name]
              row << type_hash[:description]
              row << units_lookup["#{extraction.id}-#{type1.id}"] if section_name == 'Outcomes'
            else
              row += [nil, nil, nil]
            end
          end
          sheet.add_row(row)
        end
      end
    end
  end

  def add_type2_sections; end

  def add_results; end
end
