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
    @key_questions_projects = KeyQuestionsProject.find args.third['kqp_ids']

    @custom_exporter = CustomExporter.new @project, @user, @column_args

    Axlsx::Package.new do |p|
      p.use_shared_strings = true
      p.use_autowidth      = true
      highlight  = p.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      wrap       = p.workbook.styles.add_style alignment: { wrap_text: true }

      p.workbook.add_worksheet(name: "Data") do |sheet|
        @custom_exporter.write_column_headers sheet, highlight
        @project.extractions.each do |ex|
          @custom_exporter.write_extraction_rows(ex, sheet, nil)
        end
      end

      p.workbook.add_worksheet(name: "Key Questions") do |sheet|
        @custom_exporter.write_key_questions @key_questions_projects, sheet, highlight
      end

      p.serialize('tmp/project_'+@project.id.to_s+'.xlsx')

     # secrets = Google::APIClient::ClientSecrets.new({
     #   "web" => {"access_token" => @user.token,
     #             "refresh_token" => @user.refresh_token,
     #             "client_id" => Rails.application.credentials[:google_apis][:client_id],
     #             "client_secret" => Rails.application.credentials[:google_apis][:client_secret]}})
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
      file_metadata = {
          # BELOW IS THE FOLDER ID, IT SHOULD BE IN A CONFIG FILE, I DON'T KNOW WHICH -BIROL
          parents: ["1ch4FAcY8yjnlyDtYnxj0mRWh4hWoIvtB"],
          name: @project.name,
          mime_type: 'application/vnd.google-apps.spreadsheet'
      }
      ## Here we specify what should server return (only the file id in this case), file location and the filetype (in this case 'xlsx')
      file = drive_service.create_file(file_metadata,
                                       fields: 'id, webViewLink',
                                       upload_source: 'tmp/project_'+@project.id.to_s+'.xlsx',
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

      # Notify the user that the export is ready for download.
      ExportMailer.notify_gsheets_export_completion(@user.id, @project.id, file.web_view_link).deliver_later
    end
  end
end

class CustomExporter
  def initialize(project, user, col_args)
    project = project
    @user = user
    @col_args = col_args

    @rows = []

    @efps_set = Set.new
    @efps_arr = []

    @type_dict = {'Descriptive' => ResultStatisticSectionType.find_by(name: 'Descriptive Statistics'),
                  'BAC' => ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons'),
                  'WAC' => ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons'),
                  'NET' => ResultStatisticSectionType.find_by(name: 'NET Change')}

    @inclusion_dict = identify_independents project, @col_args

    @t1_efps_dict = create_efps_dict @inclusion_dict, @efps_arr

    #### COMPUTE COMPARATE LENGTH ####
    @comparate_1_length, @comparate_2_length = get_comparate_lengths(project)
    #### COLUMN HEADERS ####
  end

  def write_column_headers(sheet, highlight)
    header_row = sheet.add_row get_headers
    header_row.style = highlight
  end

  def write_key_questions(kqp_arr, sheet, highlight)
    kq_header_row = sheet.add_row ["", "Key Questions"]
    kq_header_row.style = highlight
    kqp_arr.each_with_index do |kqp, i|
      sheet.add_row [(i + 1).to_s, kqp.key_question.name]
    end
  end

  def write_extraction_rows(extraction, sheet, highlight)
    combination_arr = get_combinations_for_extraction extraction
    row_prefix = [extraction.citations_project.citation.id.to_s,
                  extraction.citations_project.citation.name,
                  get_username]

    combination_arr.each do |current_combination|
      current_row = row_prefix + get_combination_data_string(current_combination, @comparate_1_length, @comparate_2_length)
      @col_args.each do |_, col_hash|
        rich_text = Axlsx::RichText.new
        col_hash['export_items'].each do |_, export_item|
          if export_item['type'] == "Type2"
            process_qids(rich_text, [export_item['export_id']], extraction, current_combination, @t1_efps_dict)
            rich_text.add_run "\n"
          else
            arm_eefpst1 = current_combination[0]
            outcome_eefpst1 = current_combination[1]
            eefpst1rc = current_combination[2]
            eefpst1r = current_combination[3]
	    begin
            rss = eefpst1r.result_statistic_sections.where(result_statistic_section_type: @type_dict[export_item['type']])&.first
            rescue
		p current_combination
	    end 
            arm_comp = current_combination[4]
            tp_comp = current_combination[5]
            process_results(rich_text, rss,[export_item['export_id']], arm_eefpst1, outcome_eefpst1, eefpst1r, eefpst1rc, arm_comp, tp_comp)
            rich_text.add_run "\n"
          end
        end
        current_row << rich_text
      end
      sheet.add_row current_row
    end
  end

  private
  def get_comparate_lengths
    [@comparate_1_length, @comparate_2_length]
  end

  def get_username
    @user.profile.username
  end

  def get_inclusion_dictionary
    @inclusion_dict
  end

  def get_type1_efps_dictionary
    @t1_efps_dict
  end

  def create_efps_dict(inclusion_dict, efps_arr)
    #other type1s
    t1_efps_dict = {}
    if inclusion_dict['arms_efps'] then t1_efps_dict[inclusion_dict['arms_efps'].id] = 0 end
    if inclusion_dict['outcomes_efps'] then t1_efps_dict[inclusion_dict['outcomes_efps'].id] = 1 end
    i = 5
    efps_arr.each do |efps|
      t1_efps_dict[efps.id] = i
      i += 1
    end
    return t1_efps_dict
  end


  def get_combinations_for_extraction(ex)
    inclusion_dict = get_inclusion_dictionary
    t1_efps_dict = get_type1_efps_dictionary

    combinable_arr = []
    arms_efps = inclusion_dict['arms_efps']
    outcomes_efps = inclusion_dict['outcomes_efps']
    include_tps = inclusion_dict['timepoints']
    include_pops = inclusion_dict['populations']
    include_comp_arms = inclusion_dict['arms_comparisons']
    include_comp_tps = inclusion_dict['timepoints_comparisons']

    if arms_efps.present?
      eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                extraction_forms_projects_section: arms_efps
      combinable_arr << eefps.extractions_extraction_forms_projects_sections_type1s.all
    else
      combinable_arr << [nil]
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
          outcome_iter_arr << current_outcome.extractions_extraction_forms_projects_sections_type1_rows.first.extractions_extraction_forms_projects_sections_type1_row_columns.all#.map{|eefpst1_r| eefpst1_r.timepoint_name}
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
              population_iter_arr << eefpst1r.result_statistic_sections.where(result_statistic_section_type_id: 3).first.comparisons.all
            else
              population_iter_arr << [nil]
            end

            pop_combinations = []
            list_combinations(population_iter_arr, 0, [], pop_combinations)

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
        list_combinations(outcome_iter_arr, 0, [], outcome_combinations)


        outcome_combinations.each do |outcome_combination|
          combined_outcome_iter_arr << [outcome_combination[0], outcome_combination[1]] + outcome_combination[2]
        end

      end
      combinable_arr << combined_outcome_iter_arr
    else
      combinable_arr << [[nil, nil, nil, nil, nil]]
    end


    t1_efps_dict.each do |efps_id, _|
      eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: ex,
                                                                extraction_forms_projects_section_id: efps_id
      combinable_arr << eefps.extractions_extraction_forms_projects_sections_type1s.all
    end

    temp_combination_arr = []
    list_combinations combinable_arr, 0, [], temp_combination_arr

    flat_combination_arr = []

    # flatten array manually
    temp_combination_arr.each do |arr_elem|
      flat_combination_arr << [arr_elem[0]] + arr_elem[1]
    end
    return flat_combination_arr.uniq
  end

  def identify_independents(project, col_args)
    inclusion_dict = {}
    other_efps_set = Set.new

    col_args.each do |_, col_hash|
      col_hash['export_items'].each do |_, export_item|
        case export_item['type']
        when "Type2"
          efps = Question.find(export_item['export_id']).extraction_forms_projects_section
          if efps.link_to_type1.present?
            if efps.link_to_type1.section.name == "Arms"
              inclusion_dict['arms_efps'] = efps.link_to_type1
            elsif efps.link_to_type1.section.name == "Outcomes"
              inclusion_dict['outcomes_efps'] = efps.link_to_type1
            else
              other_efps_set << efps.link_to_type1
              #inclusion_dict['other_t1_efps'] << efps.link_to_type1
            end
          end

        else # Results
          rssm = ResultStatisticSectionsMeasure.find export_item['export_id']
	  p rssm
          rss_type = rssm\
                 .result_statistic_section\
                 .result_statistic_section_type\
                 .name

          case rss_type
          when "Descriptive Statistics"
            #outcomes
            inclusion_dict['outcomes_efps'] ||= project\
                                               .extraction_forms_projects\
                                               .first\
                                               .extraction_forms_projects_sections\
                                               .where(section: Section.find_by(name: "Outcomes"))\
                                               .first
            #arms
            inclusion_dict['arms_efps'] ||= project\
                                           .extraction_forms_projects\
                                           .first.extraction_forms_projects_sections\
                                           .where(section: Section.find_by(name: "Arms"))\
                                           .first
            #populations
            inclusion_dict['populations'] = true
            #timepoints
            inclusion_dict['timepoints'] = true
          when "Between Arm Comparisons"
            #outcomes
            inclusion_dict['outcomes_efps'] ||= project\
                                               .extraction_forms_projects\
                                               .first\
                                               .extraction_forms_projects_sections\
                                               .where(section: Section.find_by(name: "Outcomes"))\
                                               .first
            #populations
            inclusion_dict['populations'] = true
            #timepoints
            inclusion_dict['timepoints'] = true

            #comp arms
            inclusion_dict['arms_comparisons'] = true
          when "Within Arm Comparisons"
            #outcomes
            inclusion_dict['outcomes_efps'] ||= project\
                                               .extraction_forms_projects\
                                               .first\
                                               .extraction_forms_projects_sections\
                                               .where(section: Section.find_by(name: "Outcomes"))\
                                               .first
            #arms
            inclusion_dict['arms_efps'] ||= project\
                                           .extraction_forms_projects\
                                           .first.extraction_forms_projects_sections\
                                           .where(section: Section.find_by(name: "Arms"))\
                                           .first
            #populations
            inclusion_dict['populations'] = true
            #comp tps
            inclusion_dict['timepoints_comparisons'] = true
          when "NET Change"
            #outcomes
            inclusion_dict['outcomes_efps'] ||= project\
                                               .extraction_forms_projects\
                                               .first\
                                               .extraction_forms_projects_sections\
                                               .where(section: Section.find_by(name: "Outcomes"))\
                                               .first
            #populations
            inclusion_dict['populations'] = true
            #comp arms
            inclusion_dict['arms_comparisons'] = true
            #comp tps
            inclusion_dict['timepoints_comparisons'] = true
          end
        end
      end
    end


    inclusion_dict['other_t1_efps'] = other_efps_set\
                                        .to_a\
                                        .sort {|a,b| a.id <=> b.id}
    return inclusion_dict
  end

  def process_question(rich_text, q, t2_eefps, eefpst1)
    q_name = q.name

    _first = true
    q.question_rows.each_with_index do |qr, ri|
      qr.question_row_columns.each_with_index do |qrc, ci|

        #if not _first then rich_text += "\n" else _first = false end
        if not _first
          rich_text.add_run("\n")
        else
          _first = false
        end

        if q.question_rows.length > 1 or qr.question_row_columns.length > 1
          rich_text.add_run(q_name + " ", :b => true)
          rich_text.add_run("(row: " + ri.to_s + ", column: " + ci.to_s + ")", :b => true, :i => true)
          rich_text.add_run(": ", :b => true)
        else
          rich_text.add_run(q_name + ": ", :b => true)
        end

        qrcf_arr = qrc.question_row_column_fields.sort { |a,b| a.id <=> b.id }
        qrc_type_id = qrc.question_row_column_type_id
        eefpsqrcf_arr = t2_eefps\
            .extractions_extraction_forms_projects_sections_question_row_column_fields.where( question_row_column_field: qrcf_arr,
                                                                                              extractions_extraction_forms_projects_sections_type1: eefpst1 )

        record_arr = Record.where( recordable_type: 'ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField',
                                   recordable_id: eefpsqrcf_arr.map { |eefpsqrcf| eefpsqrcf.id } ).sort { |a,b| a.recordable_id <=> b.recordable_id }

        if record_arr.empty? or record_arr.first.name.nil? then next end

        case qrc_type_id
        when 1
          if record_arr.length == 1
            rich_text.add_run(record_arr.first.name.to_s)
          end
        when 2
          if record_arr.length == 1
            rich_text.add_run(record_arr.first.name.to_s)
          elsif record_arr.length == 2
            #rich_text += record_arr.first.name.to_s + " " + record_arr.second.name.to_s
            rich_text.add_run(record_arr.first.name.to_s + " " + record_arr.second.name.to_s)
          end
        when 3
          #nothing
        when 4
          #nothing
        when 5
          if record_arr.length == 1
            option_names = (record_arr.first.name[2..-3].split('", "') - [""]).map { |r| QuestionRowColumnsQuestionRowColumnOption.find(r.to_i).name }
            rich_text.add_run( '["' + option_names.join('", "') + '"]' )
          end
        when 6,7,8
          if record_arr.length == 1
            rich_text.add_run(QuestionRowColumnsQuestionRowColumnOption.find_by(id: record_arr.first.name.to_i)&.name || "")
          end

        when 9
          #problematic
        end
      end
    end
    return rich_text
  end


  def process_qids(rich_text, qid_arr, extraction, combination, t1_efps_dict)
    qid_arr.each do |qid|
      q = Question.find qid

      t2_eefps = ExtractionsExtractionFormsProjectsSection.find_by extraction: extraction,
                                                                extraction_forms_projects_section: q.extraction_forms_projects_section
      t1_efps = q.extraction_forms_projects_section.link_to_type1

      if t1_efps.present?
        eefpst1 = combination[t1_efps_dict[t1_efps.id]]
      end
      process_question(rich_text, q, t2_eefps, eefpst1)
    end

    return rich_text
  end

  def get_headers
    header_arr = ["Study ID", "Study Title", "Username"]
    inclusion_dict = get_inclusion_dictionary

    if inclusion_dict['arms_efps'].present? then header_arr << "Arm" end
    if inclusion_dict['outcomes_efps'].present? then header_arr << "Outcome" end
    if inclusion_dict['populations'] then header_arr << "Population" end
    if inclusion_dict['timepoints'] then header_arr << "Timepoint" end
    if inclusion_dict['arms_comparisons']
      header_arr += ((1..(@comparate_1_length + @comparate_2_length)).map.with_index { |x, i| "Arm #{(i+1).to_s}"})
      header_arr << "Comparison"
    end
    if inclusion_dict['timepoints_comparisons']
      header_arr << "Timepoint 1"
      header_arr << "Timepoint 2"
      header_arr << "Comparison"
    end
    @efps_arr.each do |t1_efps|
      header_arr << t1_efps.section.name
    end

    @col_args.each do |_, chash|
      header_arr << chash['name']
    end

    return header_arr
  end

  def get_combination_data_string(combination, comp1_length, comp2_length)
    string_arr = []
    if combination[0].present? then string_arr << combination[0].type1.name end
    if combination[1].present? then string_arr << combination[1].type1.name end
    if combination[3].present? then string_arr << combination[3].population_name.name end
    if combination[2].present? then string_arr << combination[2].timepoint_name.name + " " + combination[2].timepoint_name.unit end
    if combination[4].present?
      if combination[4].comparate_groups.length == 0
        string_arr += ([""] * (comp1_length + comp2_length + 1))
      else
        comp1_string_arr = combination[4].comparate_groups.first.comparates.all.map{ |c| c.comparable_element.comparable.type1.name }
        comp2_string_arr = combination[4].comparate_groups.second.comparates.all.map{ |c| c.comparable_element.comparable.type1.name }

        string_arr += (comp1_string_arr + ([""] * (combination[4].comparate_groups.first.comparates.length - comp1_length)))
        string_arr += (comp2_string_arr + ([""] * (combination[4].comparate_groups.second.comparates.length - comp2_length)))
        string_arr << comp1_string_arr.map.with_index { |x, i| "Arm #{i + 1}"}.join(' and ') + " vs. " + comp2_string_arr.map.with_index { |x, i| "Arm #{comp1_string_arr.length + i + 1}"}.join(' and ')
      end
    end
    if combination[5].present?
      if combination[5].comparate_groups.length == 0
        string_arr += ([""] * 3)
      else
        tp1 = combination[5].comparate_groups.first.comparates.first.comparable_element.comparable
        tp2 = combination[5].comparate_groups.second.comparates.first.comparable_element.comparable
        string_arr << tp1.timepoint_name.name + " " + tp1.timepoint_name.unit
        string_arr << tp2.timepoint_name.name + " " + tp2.timepoint_name.unit
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

  def process_results(rich_text, rss, mid_arr, arm_eefpst1, outcome_eefpst1, eefpst1r, eefpst1rc, arm_comp, tp_comp)
    _first = true

    (mid_arr || []).each do |mid|
      #if not _first then rich_text += "\n" else _first = false end
      if not _first
        rich_text.add_run("\n")
      else
        _first = false
      end
      #rssm = ResultStatisticSectionsMeasure.find_by result_statistic_section: rss, measure: Measure.find(mid)
      rssm = ResultStatisticSectionsMeasure.find mid
      rss = rssm.result_statistic_section
      #rich_text += (rssm.measure.name+ ": ")
      rich_text.add_run(rssm.measure.name + ": ", :b => true)

      case rss.result_statistic_section_type_id
      when 1
        r_elem = TpsArmsRssm.find_by timepoint: eefpst1rc,
                                     extractions_extraction_forms_projects_sections_type1: arm_eefpst1,
                                     result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "TpsArmsRssm"
          #rich_text += r&.name || ""
          rich_text.add_run(r&.name || "")
        end
      when 2
        r_elem = TpsComparisonsRssm.find_by timepoint: eefpst1rc,
                                            comparison: arm_comp,
                                            result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "TpsComparisonsRssm"
          #rich_text += r&.name || ""
          rich_text.add_run(r&.name || "")
        end
      when 3
        r_elem = ComparisonsArmsRssm.find_by comparison: tp_comp,
                                             extractions_extraction_forms_projects_sections_type1: arm_eefpst1,
                                             result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "ComparisonsArmsRssm"
          #rich_text += r&.name || ""
          rich_text.add_run(r&.name || "")
        end
      when 4
        r_elem = WacsBacsRssm.find_by wac: tp_comp,
                                      bac: arm_comp,
                                      result_statistic_sections_measure: rssm
        if r_elem.present?
          r = Record.find_by recordable_id: r_elem.id, recordable_type: "WacsBacsRssm"
          #rich_text += r&.name || ""
          rich_text.add_run(r&.name || "")
        end
      end
    end

    return rich_text
  end

  def list_combinations(arr_of_arrs, n, prefix, result_arr)
    if n >= arr_of_arrs.length
      result_arr << prefix
      return
    else
      arr_of_arrs[n].each do |elem|
        new_prefix = prefix + [elem]
        list_combinations arr_of_arrs, n+1, new_prefix, result_arr
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
