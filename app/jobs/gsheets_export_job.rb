require 'simple_export_job/_se_project_information_section'
require 'simple_export_job/_se_type1_sections_compact'
require 'simple_export_job/_se_type1_sections_wide'
require 'simple_export_job/_se_type2_sections_compact'
require 'simple_export_job/_se_type2_sections_wide'
require 'simple_export_job/_se_result_sections_compact'
require 'simple_export_job/_se_result_sections_wide'
require 'simple_export_job/_se_sample_3d_pie_chart'

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
