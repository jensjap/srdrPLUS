Dir[File.join(__dir__, 'simple_export_job', '_*.rb')].each { |file| require file }

require 'simple_export_job/legacy_exporter'
require 'google/api_client/client_secrets.rb'
require 'google/apis/drive_v3'

class SimpleExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  rescue_from(StandardError) do |exception|
    Sentry.capture_exception(exception) if Rails.env.production?
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second, exception.message).deliver_later
  end

  def perform(*args)
    Axlsx::Package.new do |package|
      @user_email = args.first
      @project = Project.
        includes({
          extractions: {
            citations_project: { citation: [:authors, :journal] }
          },
          extraction_forms_projects: {
            extraction_forms_projects_sections: [
              :section,
              :extraction_forms_projects_section_option,
              extractions_extraction_forms_projects_sections: {
                extractions_extraction_forms_projects_sections_type1s: :type1
              }
            ]
          }
        }).
        find(args.second)
      @export_type = args.third
      @package = package
      @package.use_shared_strings = true
      @package.use_autowidth = true
      @highlight = @package.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      @wrap = @package.workbook.styles.add_style alignment: { wrap_text: true }

      Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
      Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"

      # Generate XLSX with basic project information.
      filename = generate_xlsx
      raise "Unable to serialize" unless @package.serialize(filename)

      if /xlsx/ =~ @export_type
        create_email_export(filename)
      elsif /Google Sheets/ =~ @export_type
        create_gdrive_export(filename)
      else
        raise "Unknown ExportType."
      end

      ExportMailer.notify_simple_export_completion(@exported_item.id).deliver_later
    end
  end

  private
    def generate_xlsx
      if /legacy/ =~ @export_type
        exporter = LegacyExporter.new(@package, @project, @highlight, @wrap)
        exporter.build!
        return 'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_legacy.xlsx'
      else
        build_project_information_section
        return build_all_other_sections_and_generate_filename
      end
    end

    def build_project_information_section
      # Sheet with basic project information.
      @package.workbook.add_worksheet(name: 'Project Information') do |sheet|
        sheet.add_row ['Project Information:'],                                     style: [@highlight]
        sheet.add_row ['Name',                    @project.name]
        sheet.add_row ['Description',             @project.description],             style: [@wrap]
        sheet.add_row ['Attribution',             @project.attribution]
        sheet.add_row ['Methodology Description', @project.methodology_description]
        sheet.add_row ['Prospero',                @project.prospero],                types: [nil, :string]
        sheet.add_row ['DOI',                     @project.doi],                     types: [nil, :string]
        sheet.add_row ['Notes',                   @project.notes]
        sheet.add_row ['Funding Source',          @project.funding_source]

        # Project member list.
        sheet.add_row ['Project Member List:'],                                     style: [@highlight]
        sheet.add_row ['Username', 'First Name', 'Middle Name', 'Last Name', 'Email', 'Extraction ID']
        @project.members.each do |user|
          sheet.add_row [
            user.username,
            user.first_name,
            user.middle_name,
            user.last_name,
            user.email,
            Extraction.by_project_and_user(@project.id, user.id).pluck(:id)
          ]
        end

        # Re-apply the styling for the new cells before closing the sheet.
        sheet.column_widths nil
      end
    end

    def build_all_other_sections_and_generate_filename
      if /wide/ =~ @export_type
        build_type1_sections_wide
        build_type2_sections_wide
        build_result_sections_wide
        return 'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_wide.xlsx'
      # elsif /legacy/ =~ @export_type
      #   # build_type1_sections_wide
      #   build_type2_sections_wide_srdr_style
      #   # build_result_sections_wide_srdr_style_2
      #   return 'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_legacy.xlsx'
      else
        build_type1_sections_compact
        build_type2_sections_compact
        build_result_sections_compact
        return 'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_long.xlsx'
      end
    end

    def create_email_export(filename)
      @export_type = ExportType.find_by(name: ".xlsx")
      @exported_item = ExportedItem.create! project: @project, user_email: @user_email, export_type: @export_type
      @exported_item.file.attach io: File.open(filename), filename: filename
      # Notify the user that the export is ready for download.
      if @exported_item.file.attached?
        @exported_item.external_url = Rails.application.routes.default_url_options[:host] + Rails.application.routes.url_helpers.rails_blob_path(@exported_item.file, only_path: true)
        @exported_item.save!
      else
        raise "Cannot attach exported file"
      end
    end

    def create_gdrive_export(filename)
      @export_type  = ExportType.find_by(name: "Google Sheets")
      drive_service = Google::Apis::DriveV3::DriveService.new
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
                                        upload_source: filename,
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

      @exported_item = ExportedItem.create! project: @project, user_email: @user_email, export_type: @export_type, external_url: file.web_view_link
    end
end