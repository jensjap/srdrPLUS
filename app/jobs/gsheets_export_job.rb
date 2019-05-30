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

    efps_set = Set.new
    include_pops = false
    include_tps = false
    include_comp_arms = false
    include_comp_tps = false
    arms_efps = nil
    outcomes_efps = nil

    @column_args.each do |i, col_hash|
      case col_hash['type']
      when "Type 2"
        efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
        if efps.section.name == "Arms"
          arms_efps = efps
        elsif efps.section.name == "Outcomes"
          outcomes_efps = efps
        elsif efps.link_to_type1.present?
          efps_set << efps.link_to_type1
        end

      when "Descriptive"
        rssm = ResultStatisticSectionsMeasure.find(col_hash['export_ids'].first)
        #outcomes
        efps_set << @project.extraction_forms_projects.first.extractions_extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #arms
        efps_set << @project.extraction_forms_projects.first.extractions_extraction_forms_projects_sections.where(section: Section.find_by(name: "Arms")).first
        #populations
        include_pops = true
        #timepoints
        include_tps = true
      when "BAC"
        #outcomes
        efps_set << @project.extraction_forms_projects.first.extractions_extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #populations
        include_pops = true
        #timepoints
        include_tps = true
        #comp arms
        include_comp_arms = true
      when "WAC"
        #outcomes
        efps_set << @project.extraction_forms_projects.first.extractions_extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #arms
        efps_set << @project.extraction_forms_projects.first.extractions_extraction_forms_projects_sections.where(section: Section.find_by(name: "Arms")).first
        #populations
        include_pops = true
        #comp tps
        include_comp_tps = true
      when "NET"
        #outcomes
        efps_set << @project.extraction_forms_projects.first.extractions_extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #populations
        include_pops = true
        #comp arms
        include_comp_arms = true
        #comp tps
        include_comp_tps = true
      end
    end

    @type_dict = {'Descriptive' => ResultStatisticSectionType.find_by(name: 'Descriptive Statistics'),
                  'BAC' => ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons'),
                  'WAC' => ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons'),
                  'NET' => ResultStatisticSectionType.find_by(name: 'NET Change')}
    @project.extractions.each do |ex|
      what_to_iter = []

      if arms_efps.present?
        eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                  extraction_forms_projects_section: arms_efps

        what_to_iter << eefps.extractions_extraction_forms_projects_sections_type1s.all
      else
        what_to_iter << [nil]
      end

      if outcomes_efps.present?
        eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                  extraction_forms_projects_section: outcomes_efps

        combined_outcome_iter_arr = []

        outcomes_eefpst1_arr = eefps.extractions_extraction_forms_projects_sections_type1s.all
        outcomes_eefpst1_arr.each do |current_outcome|
          outcome_iter_arr = [[current_outcome]]

          # tps
          if include_tps
            outcome_iter_arr << current_outcome.extractions_extraction_forms_projects_sections_type1_row_columns.all#.map{|eefpst1_r| eefpst1_r.timepoint_name}
          else
            outcome_iter_arr << [nil]
          end

          if include_pops
            eefpst1r_arr = current_outcome.extractions_extraction_forms_projects_sections_type1_rows.all

            combined_pop_combinations = []

            eefpst1r_arr.each do |eefpst1r|
              population_iter_arr = [[eefpst1r]]#.population_name]]

              # arms comparisons
              if include_comp_arms
                population_iter_arr << eefpst1r.result_statistic_sections.where(result_statistic_section_type_id: 2).first.comparisons.all
              else
                population_iter_arr << [nil]
              end

              # tps comparisons
              if include_comp_tps
                population_iter_arr << eefpst1r.result_statistic_sections.where(result_statistic_section_type_id: 2).first.comparisons.all
              else
                population_iter_arr << [nil]
              end

              pop_combinations = []
              combined_pop_combinations << get_combinations(population_iter_arr, 0, [], pop_combinations)
            end

            #  [[pop, arms_comp, tps_comp]]
            outcome_iter_arr << combined_pop_combinations
          else
            #  [[pop, arms_comp, tps_comp]]
            outcome_iter_arr << [[nil, nil, nil]]
          end

          outcome_combinations = []
          get_combinations(outcome_iter_arr, 0, [], outcome_combinations)
          combined_outcome_iter_arr << [ outcome_combinations[0] ] + outcome_combinations[1]
        end
        what_to_iter << combined_outcome_iter_arr
      else
        what_to_iter << [[nil, nil, nil, nil, nil]]
      end

      #other type1s
      @t1_efps_dict = {arms_efps.id => 0, outcomes_efps => 1}
      i = 5
      efps_set.each do |efps|
        eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                  extraction_forms_projects_section: efps

        what_to_iter << eefps.extractions_extraction_forms_projects_sections_type1s.all
        @t1_efps_dict[efps.id] = i
        i += 1
      end

      combination_arr = []
      get_combinations what_to_iter, 0, [], combination_arr

      flat_combination_arr = [combination_arr[0]] + combination_arr[1] + combination_arr[2..-1]

      flat_combination_arr.each do |current_combination|
        #current_row = [ex.citations_project.citation.id.to_s, ex.citations_project.citation.name, @user.profile.username] + t1_efps_non_nil_indices.map { |i| t1_combination[i].name }
        current_row = []
        @column_args.each do |i, col_hash|
          if col_hash['type'] == "Type 2"
            efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
            eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction_id: ex.id, extraction_forms_projects_section_id: efps.id
            t1_efps = efps.link_to_type1

            if t1_efps.present?
              eefpst1 = current_combination[@t1_efps_dict[t1_efps.id]]
            end

            current_row << get_question_data_string(eefps, eefpst1, col_hash['export_ids'])
          else
            rss = @type_dict[col_hash['type']]
            eefpst1rc = current_combination[3]
            arm_eefpst1 = current_combination[0]
            arm_comp = current_combination[4]
            tp_comp = current_combination[5]
            current_row << get_results_data_string(rss, col_hash['export_ids'], arm_eefpst1, eefpst1rc, arm_comp, tp_comp)
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

  def get_question_data_string(eefps, eefpst1, qid_arr)
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
          eefpsqrcf_arr = eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.where( question_row_column_field: qrcf_arr, extractions_extraction_forms_projects_sections_type1: eefpst1 )
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

  def get_combination_headers combination
  end

  def get_combination_data_string combination
    combination.each do
  end

  def get_results_data_string(rss, mid_arr, arm_eefpst1, eefpst1rc, arm_comp, tp_comp)
    _first = true

    data_string = ""

    mid_arr.each do |mid|
      if not _first then data_string += "\n" else _first = false end
      rssm = ResultStatisticSectionsMeasure.find_by result_statistic_section: rss, measure: Measure.find(mid)
      data_string += (rssm.measure.name+ ": ")

      case rss.result_statistic_section_type_id
      when 1
        r_elem = TpsArmsRssm.find_by timepoint: eefpst1rc,
                                     extractions_extraction_forms_projects_sections_type1: arm_eefpst1,
                                     result_statistic_sections_measure: rssm
        r = Record.find_by recordable_id: r_elem.id, recordable_type: "TpsArmsRssm"
        data_string += r&.name || ""
      when 2
        r_elem = TpsComparisonsRssm.find_by timepoint: eefpst1rc,
                                            comparison: arm_comp,
                                            result_statistic_sections_measure: rssm
        r = Record.find_by recordable_id: r_elem.id, recordable_type: "TpsComparisonsRssm"
        data_string += r&.name || ""
      when 3
        r_elem = ComparisonsArmsRssm.find_by comparison: tp_comp,
                                             arm: arm_eefpst1,
                                             result_statistic_sections_measure: rssm
        r = Record.find_by recordable_id: r_elem.id, recordable_type: "ComparisonsArmsRssm"
        data_string += r&.name || ""
      when 4
        r_elem = WacsBacsRssm.find_by wac: tp_comp,
                                      bac: arm_comp,
                                      result_statistic_sections_measure: rssm
        r = Record.find_by recordable_id: r_elem.id, recordable_type: "WacsBacsRssm"
        data_string += r&.name || ""
      end
    end

    return data_string
  end

  end

  def get_combinations(arr_of_arrs, n, prefix, result_arr)
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
