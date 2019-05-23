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

    column_headers = ["Study ID", "Study Title", "Username"]

    @rows = []
    t1_efps_set = Set.new
    t1_efps_arr = []
    t1_arr = []
    efps_id_to_combination_index = {}


    @column_args.each do |col_hash|
      if col_hash['type'] == "Type 2"
        efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
        if efps.link_to_type1.present?
          t1_efps_set << efps.link_to_type1
          if efps.extraction_forms_projects_section_option.by_type1
            t1_efps_arr << efps.link_to_type1
          else
            t1_efps_arr << nil
          end
        else
          t1_efps_arr << nil
        end
      end
    end

    @project.extractions.each do |ex|
      #@t1_efps_set.to_a.sort{ |a,b| a.id <=> b.id }.each do |t1_efps|
      t1_efps_set.each_with_index do |t1_efps, i|
        if t1_efps.extraction_forms_projects_section_option.by_type1
          t1_arr << ExtractionsExtractionFormsProjectsSection.find_by( extraction_forms_projects_section: t1_efps,\
                                                                        extraction: ex ).type1s.all
        else
          t1_arr << [nil]
        end
        efps_id_to_combination_index[t1_efps.id] = i
      end

      combination_arr = []
      get_combinations t1_arr, 0, [], combination_arr

      combination_arr.each do |t1_combination|
        current_row = []
        @column_args.each_with_index do |col_hash, i|
          case col_hash['type']
          when "Type 2"
            efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
            eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction_id: ex.id, extraction_forms_projects_section_id: efps.id
            t1_efps = t1_efps_arr[i]
            t1 = nil
            if t1_efps.present?
              t1 = t1_combination[efps_id_to_combination_index[t1_efps.id]]
            end

            current_row << get_question_data_string eefps, t1, col_hash['export_ids']
          when "Descriptive"
          when "BAC"
          when "WAC"
          when "NET"
          end
        end
        @rows << current_row
      end
    end

    byebug

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

  def get_question_data_string eefps, t1, qid_arr
    _first = true

    qid_arr.each do |qid|
      q = Question.find qid
      q_name = q.name
      data_string = ""

      q.question_rows.each_with_index do |qr, ri|
        qr.question_row_columns.each_with_index do |qrc, ci|

          if not _first then data_string += "\n"; _first = false end

          if q.question_rows.length > 1 or qr.question_row_columns.length > 1
            data_string += (q_name + " (row: " + ri.to_s ", column: " + ci.to_s + "): ")
          else
            data_string += (q_name + ": ")
          end

          qrcf_arr = qrc.question_row_column_fields.sort { |a,b| a.id <=> b.id }
          qrc_type_id = qrc.question_row_column_type_id
          eefpsqrcf_arr = eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.where( question_row_column_field: qrcf_arr, extractions_extraction_forms_projects_sections_type1: ExtractionsExtractionFormsProjectsSectionsType1.find_by( extractions_extraction_forms_projects_section: eefps, type1: t1 ))
          record_arr = Record.where( recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                     recordable_id: eefpsqrcf_arr.map { |eefpsqrcf| eefpsqrcf.id } ).sort { |a,b| a.recordable_id <=> b.recordable_id }
          case qrc_type_id
          when 1
            if record_arr.length == 1
              data_string += record_arr.first.name
            end
          when 2
            if record_arr.length == 1
              data_string += record_arr.first.name
            elsif record_arr.length == 2
              data_string += record_arr.first.name.to_s + " " + record_arr.second.name.to_s
            end
          when 3
            #nothing
          when 4
            #nothing
          when 5
            if record_arr.length == 1
              option_names = (record_arr.first.name[1..-2].split(", ") - ['""']).map { |r| QuestionRowColumnsQuestionRowColumnOption.find(r.to_i).name }
              data_string += '["' + option_names.join('", "') + '"]'
            end
          when 6,7,8
            if record_arr.length == 1
              data_string += QuestionRowColumnsQuestionRowColumnOption.find(record_arr.first.name).name
            end

          when 9
            #problematic
          end
        end
      end
    end
  end

  def get_combinations arr_of_arrs, n, prefix, result_arr
    if n >= arr_of_arrs.length
      result_arr << prefix
      return
    else
      arr_of_arrs[n].each do |elem|
        new_prefix = prefix + [elem]
        get_combinations arr_of_arrs, n+1, new_prefix, result_arr
      end
    end
  end
end
