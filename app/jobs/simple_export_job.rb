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

class SimpleExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  rescue_from(StandardError) do |exception|
       # Do something with the exception
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second, exception.message).deliver_later
  end

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user             = User.find args.first
    @project          = Project.find args.second

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

      f_name = 'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '.xlsx'
      if p.serialize(f_name)
        export_type  = ExportType.find_by name: args.third
        case export_type.name
        when '.xlsx'
          exported_item = ExportedItem.create! projects_user: ProjectsUser.find_by( project: @project, user: @user), export_type: export_type

          exported_item.file.attach io: File.open(f_name), filename: f_name
          # Notify the user that the export is ready for download.
          if exported_item.file.attached?
            exported_item.external_url = exported_item.file.service_url
            exported_item.save!
            ExportMailer.notify_simple_export_completion(exported_item.id).deliver_later
          else
            raise "Cannot attach exported file"
          end
        when 'Google Sheets'
          drive_service = Google::Apis::DriveV3::DriveService.new
         #service.authorization = secrets.to_authorization
          drive_service.authorization = ::Google::Auth::ServiceAccountCredentials.new( token_credential_uri: Google::Auth::ServiceAccountCredentials::TOKEN_CRED_URI,
                                          audience: Google::Auth::ServiceAccountCredentials::TOKEN_CRED_URI,
                                          scope: 'https://www.googleapis.com/auth/drive',
                                          issuer: Rails.application.credentials[:google_service_account][:client_email],
                                          signing_key: OpenSSL::PKey::RSA.new(Rails.application.credentials[:google_service_account][:private_key]))

          callback = lambda do |res, err|
            if err
              # Handle error...
              puts err.body
            else
              puts "Permission ID: #{res.id}"
            end
          end

          ## This metadata specifies resulting file name and what it should be converted into (in this case 'Google Sheets')
          ## BELOW IS THE FOLDER ID, IT SHOULD BE IN A CONFIG FILE, I DON'T KNOW WHICH -BIROL
          file_metadata = {
              parents: ["1ch4FAcY8yjnlyDtYnxj0mRWh4hWoIvtB"],
              name: @project.name,
              mime_type: 'application/vnd.google-apps.spreadsheet'
          }
          ## Here we specify what should server return (only the file id in this case), file location and the filetype (in this case 'xlsx')
          file = drive_service.create_file(file_metadata,
                                           fields: 'id, webViewLink',
                                           upload_source: f_name,
                                           content_type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet')
          domain_permission = {
              type: 'anyone',
              role: 'reader'
          }

          drive_service.create_permission(file.id,
                                    domain_permission,
                                    fields: 'id',
                                    &callback)


          puts "File Id: #{file.id}"
          puts "File Link: #{file.web_view_link}"

          exported_item = ExportedItem.create! projects_user: ProjectsUser.find_by( project: @project, user: @user), export_type: export_type, external_url: file.web_view_link

          ExportMailer.notify_simple_export_completion(exported_item.id).deliver_later
        end
      end
    end
  end
end
