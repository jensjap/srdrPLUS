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
    @column_args = args.third['columns']

    @rows = []
    t1_efps_set = Set.new
    t1_efps_set << nil
    t1_efps_arr = []
    efps_id_to_combination_index = {}

    @column_args.each do |i, col_hash|
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

    _first = true
    @column_headers = ["Study ID", "Study Title", "Username"]
    t1_efps_non_nil_indices = []
    @project.extractions.each do |ex|
      #@t1_efps_set.to_a.sort{ |a,b| a.id <=> b.id }.each do |t1_efps|
      t1_arr = []
      t1_efps_set.each_with_index do |t1_efps, i|
        if t1_efps
          if _first then t1_efps_non_nil_indices << i; @column_headers << t1_efps.section.name end
          t1_arr << ExtractionsExtractionFormsProjectsSection.find_by( extraction_forms_projects_section: t1_efps,\
                                                                        extraction: ex ).type1s.all
        else
          t1_arr << [nil]
        end
        efps_id_to_combination_index[t1_efps&.id] = i
      end

      combination_arr = []
      get_combinations t1_arr, 0, [], combination_arr

      combination_arr.each do |t1_combination|
        current_row = [ex.citations_project.citation.id.to_s, ex.citations_project.citation.name, @user.profile.username] + t1_efps_non_nil_indices.map { |i| t1_combination[i].name }
        @column_args.each do |i, col_hash|
          case col_hash['type']
          when "Type 2"
            efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
            eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction_id: ex.id, extraction_forms_projects_section_id: efps.id
            t1_efps = t1_efps_arr[i.to_i]
            t1_eefps = if t1_efps then ExtractionsExtractionFormsProjectsSection.find_by extraction_id: ex.id, extraction_forms_projects_section_id: t1_efps.id else nil end

            t1 = nil
            if t1_efps.present? then t1 = t1_combination[efps_id_to_combination_index[t1_efps&.id]] end

            current_row << get_question_data_string( eefps, t1_eefps, t1, col_hash['export_ids'] )
          when "Descriptive"
          when "BAC"
          when "WAC"
          when "NET"
          end
        end
        @rows << current_row
      end
      _first = false
    end

    @column_headers += @column_args.map { |i, c| c['column_name'] }

    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"

    Axlsx::Package.new do |p|
      p.use_shared_strings = true
      p.use_autowidth      = true
      highlight  = p.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      wrap       = p.workbook.styles.add_style alignment: { wrap_text: true }


      p.workbook.add_worksheet(name: "KEY QUESTION NAME") do |sheet|
        sheet.add_row @column_headers
        @rows.each do |row|
          sheet.add_row row
        end
      end

      p.serialize('tmp/project_'+@project.id.to_s+'.xlsx')

      secrets = Google::APIClient::ClientSecrets.new({
        "web" => {"access_token" => @user.token,
                  "refresh_token" => @user.refresh_token,
                  "client_id" => Rails.application.credentials[:google_apis][:client_id],
                  "client_secret" => Rails.application.credentials[:google_apis][:client_secret]}})
      service = Google::Apis::DriveV3::DriveService.new
      service.authorization = secrets.to_authorization


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
      ExportMailer.notify_gsheets_export_completion(@user.id, @project.id, file.web_content_link).deliver_later
    end
  end

  def get_question_data_string eefps, t1_eefps, t1, qid_arr
    _first = true

    data_string = ""

    qid_arr.each do |qid|
      q = Question.find qid
      q_name = q.name

      q.question_rows.each_with_index do |qr, ri|
        qr.question_row_columns.each_with_index do |qrc, ci|

          if not _first then data_string += "\n" else _first = false end

          if q.question_rows.length > 1 or qr.question_row_columns.length > 1
            data_string += (q_name + " (row: " + ri.to_s + ", column: " + ci.to_s + "): ")
          else
            data_string += (q_name + ": ")
          end

          qrcf_arr = qrc.question_row_column_fields.sort { |a,b| a.id <=> b.id }
          qrc_type_id = qrc.question_row_column_type_id
          eefpsqrcf_arr = eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.where( question_row_column_field: qrcf_arr, extractions_extraction_forms_projects_sections_type1: ExtractionsExtractionFormsProjectsSectionsType1.find_by( extractions_extraction_forms_projects_section: t1_eefps, type1: t1 ))
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
              option_names = (record_arr.first.name[2..-3].split('", "') - [""]).map { |r| QuestionRowColumnsQuestionRowColumnOption.find(r.to_i).name }
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

    return data_string
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
