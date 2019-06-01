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
    @column_args = args.third['payload']

    @rows = []

    @efps_arr = Set.new
    @include_pops = false
    @include_tps = false
    @include_comp_arms = false
    @include_comp_tps = false
    @arms_efps = nil
    @outcomes_efps = nil

    @column_args.each do |i, col_hash|
      case col_hash['type']
      when "Type2"
        efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
        if efps.link_to_type1.present?
          if efps.link_to_type1.section.name == "Arms"
            @arms_efps = efps.link_to_type1
          elsif efps.link_to_type1.section.name == "Outcomes"
            @outcomes_efps = efps.link_to_type1
          else
            @efps_arr << efps.link_to_type1
          end
        end

      when "Descriptive"
        #outcomes
        @outcomes_efps = @project.extraction_forms_projects.first.extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #arms
        @arms_efps = @project.extraction_forms_projects.first.extraction_forms_projects_sections.where(section: Section.find_by(name: "Arms")).first
        #populations
        @include_pops = true
        #timepoints
        @include_tps = true
      when "BAC"
        #outcomes
        @outcomes_efps = @project.extraction_forms_projects.first.extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #populations
        @include_pops = true
        #timepoints
        @include_tps = true
        #comp arms
        @include_comp_arms = true
      when "WAC"
        #outcomes
        @outcomes_efps = @project.extraction_forms_projects.first.extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #arms
        @arms_efps = @project.extraction_forms_projects.first.extraction_forms_projects_sections.where(section: Section.find_by(name: "Arms")).first
        #populations
        @include_pops = true
        #comp tps
        @include_comp_tps = true
      when "NET"
        #outcomes
        @outcomes_efps = @project.extraction_forms_projects.first.extraction_forms_projects_sections.where(section: Section.find_by(name: "Outcomes")).first
        #populations
        @include_pops = true
        #comp arms
        @include_comp_arms = true
        #comp tps
        @include_comp_tps = true
      end
    end

    @efps_arr = @efps_arr.to_a

    @type_dict = {'Descriptive' => ResultStatisticSectionType.find_by(name: 'Descriptive Statistics'),
                  'BAC' => ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons'),
                  'WAC' => ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons'),
                  'NET' => ResultStatisticSectionType.find_by(name: 'NET Change')}

    #### COMPUTE COMPARATE LENGTH ####
    @comparate_1_length, @comparate_2_length = get_comparate_lengths(@project)
    #### COLUMN HEADERS ####
    @column_headers = ["Study ID", "Study Title", "Username"] + get_headers(@comparate_1_length, @comparate_2_length)

    @project.extractions.each do |ex|
      what_to_iter = []

      if @arms_efps.present?
        eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                  extraction_forms_projects_section: @arms_efps

        what_to_iter << eefps.extractions_extraction_forms_projects_sections_type1s.all
      else
        what_to_iter << [nil]
      end

      if @outcomes_efps.present?
        eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                  extraction_forms_projects_section: @outcomes_efps

        combined_outcome_iter_arr = []

        outcomes_eefpst1_arr = eefps.extractions_extraction_forms_projects_sections_type1s.all
        outcomes_eefpst1_arr.each do |current_outcome|
          outcome_iter_arr = [[current_outcome]]

          # tps
          if @include_tps
            outcome_iter_arr << current_outcome.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.all#.map{|eefpst1_r| eefpst1_r.timepoint_name}
          else
            outcome_iter_arr << [nil]
          end

          if @include_pops
            eefpst1r_arr = current_outcome.extractions_extraction_forms_projects_sections_type1_rows.all

            combined_pop_combinations = []

            eefpst1r_arr.each do |eefpst1r|
              population_iter_arr = [[eefpst1r]]#.population_name]]

              # arms comparisons
              if @include_comp_arms
                population_iter_arr << eefpst1r.result_statistic_sections.where(result_statistic_section_type_id: 2).first.comparisons.all
              else
                population_iter_arr << [nil]
              end

              # tps comparisons
              if @include_comp_tps
                population_iter_arr << eefpst1r.result_statistic_sections.where(result_statistic_section_type_id: 3).first.comparisons.all
              else
                population_iter_arr << [nil]
              end

              pop_combinations = []
              get_combinations(population_iter_arr, 0, [], pop_combinations)

              pop_combinations.each do |pop_combination|
                combined_pop_combinations << pop_combination
              end
            end

            #  [[pop, arms_comp, tps_comp]]
            outcome_iter_arr << combined_pop_combinations
          else
            #  [[pop, arms_comp, tps_comp]]
            outcome_iter_arr << [[nil, nil, nil]]
          end
          outcome_combinations = []
          get_combinations(outcome_iter_arr, 0, [], outcome_combinations)


          outcome_combinations.each do |outcome_combination|
            begin
              combined_outcome_iter_arr << [outcome_combination[0], outcome_combination[1]] + outcome_combination[2]
            rescue
              byebug
            end
          end

        end
        what_to_iter << combined_outcome_iter_arr
      else
        what_to_iter << [[nil, nil, nil, nil, nil]]
      end

      #other type1s
      @t1_efps_dict = {}
      if @arms_efps then @t1_efps_dict[@arms_efps.id] = 0 end
      if @outcomes_efps then @t1_efps_dict[@outcomes_efps.id] = 1 end
      i = 5
      @efps_arr.each do |efps|
        eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                  extraction_forms_projects_section: efps

        what_to_iter << eefps.extractions_extraction_forms_projects_sections_type1s.all
        @t1_efps_dict[efps.id] = i
        i += 1
      end

      combination_arr = []
      get_combinations what_to_iter, 0, [], combination_arr

      flat_combination_arr = []
      arm_comparison_arr = []

      # flatten array manually
      combination_arr.each do |arr_elem|
        begin
          flat_combination_arr << [arr_elem[0]] + arr_elem[1]
          arm_comparison_arr << arr_elem[1][3]
        rescue
          byebug
        end
      end

      flat_combination_arr.each do |current_combination|
        #current_row = [ex.citations_project.citation.id.to_s, ex.citations_project.citation.name, @user.profile.username] + t1_efps_non_nil_indices.map { |i| t1_combination[i].name }
        current_row = [ex.citations_project.citation.id.to_s, ex.citations_project.citation.name, @user.profile.username] + get_combination_data_string(current_combination, @comparate_1_length, @comparate_2_length)
        @column_args.each do |i, col_hash|
          if col_hash['type'] == "Type2"
            efps = Question.find( col_hash['export_ids'].first ).extraction_forms_projects_section
            eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction_id: ex.id, extraction_forms_projects_section_id: efps.id
            t1_efps = efps.link_to_type1

            if t1_efps.present?
              eefpst1 = current_combination[@t1_efps_dict[t1_efps.id]]
            end

            current_row << get_question_data_string(eefps, eefpst1, col_hash['export_ids'])
          else
            arm_eefpst1 = current_combination[0]
            outcome_eefpst1 = current_combination[1]
            eefpst1rc = current_combination[2]
            eefpst1r = current_combination[3]
            rss = eefpst1r.result_statistic_sections.where(result_statistic_section_type: @type_dict[col_hash['type']]).first
            arm_comp = current_combination[4]
            tp_comp = current_combination[5]
            current_row << get_results_data_string(rss, col_hash['export_ids'], arm_eefpst1, outcome_eefpst1, eefpst1r, eefpst1rc, arm_comp, tp_comp)
          end
        end
        @rows << current_row
      end
      _first = false
    end


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

          if record_arr.empty? or record_arr.first.name.nil? then next end

          case qrc_type_id
          when 1
            if record_arr.length == 1
              data_string += record_arr.first.name.to_s
            end
          when 2
            if record_arr.length == 1
              data_string += record_arr.first.name.to_s
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
              data_string += QuestionRowColumnsQuestionRowColumnOption.find(record_arr.first.name.to_i).name
            end

          when 9
            #problematic
          end
        end
      end
    end

    return data_string
  end

  def get_headers comp1_length, comp2_length
    string_arr = []
    if @arms_efps.present? then string_arr << "Arm" end
    if @outcomes_efps.present? then string_arr << "Outcome" end
    if @include_pops then string_arr << "Population" end
    if @include_tps then string_arr << "Timepoint" end
    if @include_comp_arms
      string_arr += ((1..(comp1_length+comp2_length)).map.with_index { |x, i| "Arm #{i}"})
      string_arr << "Comparison"
    end
    if @include_comp_tps
      string_arr << "Timepoint 1"
      string_arr << "Timepoint 2"
      string_arr << "Comparison"
    end
    @efps_arr.each do |t1_efps|
      string_arr << t1_efps.section.name
    end

    @column_args.each do |i, chash|
      string_arr << chash['column_name']
    end

    return string_arr
  end

  def get_combination_data_string combination, comp1_length, comp2_length
    string_arr = []
    #combination.each do |c_elem|
      #if c_elem.nil? then next end
      #case c_elem.class.name
      #when "ExtractionsExtractionFormsProjectsSectionType1"
      #  string_arr << c_elem.type1.name
      #when "ExtractionsExtractionFormsProjectsSectionType1Row"
      #  string_arr << c_elem.population_name.name
      #when "ExtractionsExtractionFormsProjectsSectionType1RowColumn"
      #  string_arr << c_elem.timepoint_name.name
      #when "Comparison"
      #  if c_elem.comparate_groups.length == 0
      #    string_arr << ([""] * (comp1_length + comp2_length))
      #  else
      #    c_elem.comparate_groups.first.comparates.map{ |c| c.comparable_element }
      #  end
      #  comp1_arr = c_elem.comparate_groups.first.
      #  comp1_arr = [nil]*comp1_length
      #  string_arr <<

      #end
    if combination[0].present? then string_arr << combination[0].type1.name end
    if combination[1].present? then string_arr << combination[1].type1.name end
    if combination[3].present? then string_arr << combination[3].population_name.name end
    if combination[2].present? then string_arr << combination[2].timepoint_name.name end
    if combination[4].present?
      if combination[4].comparate_groups.length == 0
        string_arr += ([""] * (comp1_length + comp2_length + 1))
      else
        comp1_string_arr = combination[4].comparate_groups.first.comparates.all.map{ |c| c.comparable_element.comparable.type1.name }
        comp2_string_arr = combination[4].comparate_groups.second.comparates.all.map{ |c| c.comparable_element.comparable.type1.name }

        string_arr += (comp1_string_arr + (combination[4].comparate_groups.first.comparates.length - comp1_length) * [""])
        string_arr += (comp2_string_arr + (combination[4].comparate_groups.second.comparates.length - comp2_length) * [""])
        string_arr << comp1_string_arr.map.with_index { |x, i| "Arm #{i}"}.join(' and ') + " vs. " + comp2_string_arr.map.with_index { |x, i| "Arm #{comp1_string_arr.length + i}"}.join(' and ')
      end
    end
    if combination[5].present?
      if combination[5].comparate_groups.length == 0
        string_arr += ([""] * 3)
      else
        begin
          string_arr << combination[5].comparate_groups.first.comparates.first.comparable_element.comparable.timepoint_name.name
        rescue
          byebug
        end
        string_arr << combination[5].comparate_groups.second.comparates.first.comparable_element.comparable.timepoint_name.name
        string_arr << "Timepoint 1 vs. Timepoint 2"
      end
    end

    if combination[6..-1].present?
      combination[6..-1].each do |eefpst1|
        string_arr << eefpst1.type1.name
      end
    end
    return string_arr
  end

  def get_results_data_string(rss, mid_arr, arm_eefpst1, outcome_eefpst1, eefpst1r, eefpst1rc, arm_comp, tp_comp)
    _first = true

    data_string = ""

    (mid_arr || []).each do |mid|
      if not _first then data_string += "\n" else _first = false end
      #rssm = ResultStatisticSectionsMeasure.find_by result_statistic_section: rss, measure: Measure.find(mid)
      rssm = ResultStatisticSectionsMeasure.find mid
      data_string += (rssm.measure.name+ ": ")

      case rss.result_statistic_section_type_id
      when 1
        r_elem = TpsArmsRssm.find_by timepoint: eefpst1rc,
                                     extractions_extraction_forms_projects_sections_type1: arm_eefpst1,
                                     result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "TpsArmsRssm"
          data_string += r&.name || ""
        end
      when 2
        r_elem = TpsComparisonsRssm.find_by timepoint: eefpst1rc,
                                            comparison: arm_comp,
                                            result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "TpsComparisonsRssm"
          data_string += r&.name || ""
        end
      when 3
        r_elem = ComparisonsArmsRssm.find_by comparison: tp_comp,
                                             extractions_extraction_forms_projects_sections_type1: arm_eefpst1,
                                             result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "ComparisonsArmsRssm"
          data_string += r&.name || ""
        end
      when 4
        r_elem = WacsBacsRssm.find_by wac: tp_comp,
                                      bac: arm_comp,
                                      result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "WacsBacsRssm"
          data_string += r&.name || ""
        end
      end
    end

    return data_string
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

  def get_comparate_lengths(project)
    comp1_length = 1
    comp2_length = 1

    ComparisonsResultStatisticSection.where(
      result_statistic_section: ResultStatisticSection.where(
        result_statistic_section_type_id: 2,
        population: ExtractionsExtractionFormsProjectsSectionsType1Row.where(
          extractions_extraction_forms_projects_sections_type1: ExtractionsExtractionFormsProjectsSectionsType1.where(
            extractions_extraction_forms_projects_section: ExtractionsExtractionFormsProjectsSection.where(
              extraction: Extraction.where(project: project),
              extraction_forms_projects_section: ExtractionFormsProjectsSection.where(
                section: Section.where(name:"Outcomes"))))))).each do |crrs|
                  comp1 = crrs.comparison.comparate_groups&.first
                  comp2 = crrs.comparison.comparate_groups&.second
                  if comp1.present? and comp1.comparates.length > comp1_length
                    comp1_length = comp1.comparates.length
                  end
                  if comp2.present? and comp2.comparates.length > comp2_length
                    comp2_length = comp2.comparates.length
                  end
    end
    return comp1_length, comp2_length
  end
end
