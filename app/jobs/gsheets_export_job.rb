require 'simple_export_job/sheet_info'

require 'google/api_client/client_secrets.rb'
require 'google/apis/drive_v3'

class GsheetsExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    @project = Project.find args.second
    @user = User.find args.first
    @column_args = args.third

    @columns = []

    @column_args.each do |col_hash|
      #c_header = q_arr.map { |q| q.name }.join ", "
      c_header = col_hash['column_name']

      case col_hash['type']
        when "Type 2"
          col_hash['ids'].each do |q|
            @project.extractions.each do |extraction|
              efps = q.extraction_forms_projects_section

              if efps.link_to_type1


              end

              eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction_id: extraction.id, extraction_forms_projects_section_id: efps.id
              if efps.extraction_forms_projects_section_option.by_type1
                eefpsqrcf_arr = eefps.\
                          extractions_extraction_forms_projects_sections_question_row_column_fields.\
                          where.not(extractions_extraction_forms_projects_sections_type1: nil)

              else
                eefpsqrcf_arr = eefps.\
                          extractions_extraction_forms_projects_sections_question_row_column_fields.\
                          where(extractions_extraction_forms_projects_sections_type1: nil)
              end
              eefpsqrcf_arr.each do |eefpsqrcf|
                record = Record.find_by recordable_id: eefpsqrcf.id,
                                        recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField'
              end
            end
          end
        when "Descriptive"
        when "BAC"
        when "WAC"
        when "NET"
      end
    end

      #{
      #    column_name: "",
      #    ids: [],
      #    type: ''
      #}


    qrcf_arr = []
    qid_arr.each do |qid|
      q = Question.find qid
      q.question_rows.each do |qr|
        qr.question_row_columns.each do |qrc|
          case qrc.question_row_column_type_id
          when 1
            #text
          when 2
            #numeric
          when 5
            #checkbox
          when 6
            #dropdown
          when 7
            #radio
          when 8
            #single
          when 9
            #multi
          end

          qrc.question_row_column_fields.each do |qrcf|

          end
        end
      end
    end


    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"

    Axlsx::Package.new do |p|
      p.use_shared_strings = true
      p.use_autowidth      = true
      highlight  = p.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      wrap       = p.workbook.styles.add_style alignment: { wrap_text: true }

      # Sheet with basic project information.
      build_project_information_section(p, @project, highlight, wrap)

      # Type 1s - compact format.
      #      build_type1_sections_compact(p, @project, highlight, wrap)

      # Type 1s - wide format.
      build_type1_sections_wide(p, @project, highlight, wrap)

      # Type 2s - compact format.
      #      build_type2_sections_compact(p, @project, highlight, wrap)

      # Type 2s - wide format.
      build_type2_sections_wide(p, @project, highlight, wrap)

      # Results - compact format.
      #      build_result_sections_compact(p, @project, highlight, wrap)

      # Results - wide format.
      build_result_sections_wide(p, @project, highlight, wrap)

      # Default sample 3D pie chart.
      build_sample_3d_pie_chart(p)

      @oob_uri = 'urn:ietf:wg:oauth:2.0:oob'
      @application_name = 'SrdrPLUS Google Drive Export'

      # The file token.yaml stores the user's access and refresh tokens, and is
      # created automatically when the authorization flow completes for the first
      # time.

      @token_path = 'token.yaml'
      @scope = Google::Apis::DriveV3::AUTH_DRIVE_FILE

      ##
      # Ensure valid credentials, either by restoring from the saved credentials
      # files or intitiating an OAuth2 authorization. If authorization is required,
      # the user's default browser will be launched to approve the request.
      #
      # @return [Google::Auth::UserRefreshCredentials] OAuth2 credentials

      secrets = Google::APIClient::ClientSecrets.new({
        "web" => {"access_token" => @user.token,
                  "refresh_token" => @user.refresh_token,
                  "client_id" => Rails.application.credentials[:google_apis][:client_id],
                  "client_secret" => Rails.application.credentials[:google_apis][:client_secret]}})
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = secrets.to_authorization

      p.serialize('tmp/project_'+@project.id.to_s+'.xlsx')

      ## This metadata specifies resulting file name and what it should be converted into (in this case 'Google Sheets')
      file_metadata = {
        name: @project.name,
        mime_type: 'application/vnd.google-apps.spreadsheet'
      }
      ## Here we specify what should server return (only the file id in this case), file location and the filetype (in this case 'xlsx')
      file = service.create_file(file_metadata,
                                 fields: 'id',
                                 upload_source: 'tmp/project_'+@project.id.to_s+'.xlsx',
                                 content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')

      puts "File Id: #{file.id}"
      # spreadsheet = service.create_spreadsheet(spreadsheet, fields: 'spreadsheetId')
      # spreadsheet_id = spreadsheet.spreadsheet_id

      # range = 'Sheet1'

      # val_range = Google::Apis::SheetsV4::ValueRange.new( values: [['TEST_HEADER', 'LOYLOY'], ['TEST_CONTENT', 'LEYLEY']] )
      # service.append_spreadsheet_value(spreadsheet_id, range, val_range, value_input_option: "RAW")

      # response = service.get_spreadsheet_values(spreadsheet_id, range)
      #
      # response.values.each do |row|
      #   # Print columns A and E, which correspond to indices 0 and 4.
      #   puts "#{row[0]}, #{row[1]}"
      # end


      # Notify the user that the export is ready for download.
      ExportMailer.notify_simple_export_completion(@user.id, @project.id).deliver_later
    end
  end
end
