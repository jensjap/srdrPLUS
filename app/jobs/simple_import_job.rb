class SimpleImportJob
  DEFAULT_HEADERS = [
    'Extraction ID',
    'Consolidated',
    'Username',
    'Citation ID',
    'Citation Name',
    'RefMan',
    'PMID',
    'Authors',
    'Publication Date',
    'Key Questions'
  ]

  TYPE2_SHEET_NAMES = {
    'Design Details' => { column_offset: 11, arms_by_rows: false },
    'Arm Details' => { column_offset: 13, arms_by_rows: true },
    'Sample Characteristics' => { column_offset: 13, arms_by_rows: true },
    'Risk of Bias - RCTs' => { column_offset: 11, arms_by_rows: false },
    'Risk of Bias - NRCSs' => { column_offset: 11, arms_by_rows: false },
    'Risk of Bias - SGSs' => { column_offset: 11, arms_by_rows: false }
  }

  RESULTS_SHEET_NAMES = [
    'Continuous - Desc. Statistics',
    'Categorical - Desc. Statistics',
    'Continuous - BAC Comparisons',
    'Categorical - BAC Comparisons'
    # 'WAC Comparisons',
    # 'NET Differences'
  ]

  attr_reader :xlsx, :sheet_names

  def initialize(filepath)
    start = Time.new
    @xlsx = Roo::Excelx.new(filepath)
    @sheet_names = @xlsx.sheets
    @errors = []
    @update_record = {
      type1and2: 0,
      type5: 0,
      type6and7and8: 0,
      type9: 0,
      typeothers: 0,
      tps_arms_rssm: 0,
      tps_comparisons_rssm: 0,
      comparisons_arms_rssm: 0,
      wacs_bacs_rssm: 0
    }
    process_type2_sections
    process_results_sections
  end

  def valid_default_headers?
    @sheet_names.each do |sheet_name|
      next if sheet_name == 'Project Information'
      sheet = @xlsx.get_sheet(sheet_name)
      no_of_col = sheet.last_column
      return false unless !!no_of_col && no_of_col > 8 && sheet.row(1)[0..9] == DEFAULT_HEADERS
    end

    true
  end

  def info
    @xlsx.info
  end

  def get_sheet(sheet_name)
    @xlsx.sheet(sheet_name)
  end

  def process_type2_sections
    TYPE2_SHEET_NAMES.each do |type2_sheet_name, settings|
      next unless @sheet_names.include?(type2_sheet_name)
      puts "processing: #{type2_sheet_name}"
      @current_sheet_name = type2_sheet_name
      process_type2_section(type2_sheet_name, settings)
      @current_sheet_name = nil
    end
  end

  def process_type2_section(sheet_name, settings)
    sheet = get_sheet(sheet_name)
    column_offset = settings[:column_offset]
    arms_by_rows = settings[:arms_by_rows]

    qrc_ids = sheet.
      row(1)[(column_offset - 1)..-1].
      map{ |header| header.split("\n")[1][/(?<=x)(.*?)(?=\])/m, 1] }

    sheet.each_with_index do |row, row_index|
      next if row_index == 0
      @current_row = row_index + 1
      extraction_id = row[0]
      dirty_answers = row[(column_offset - 1)..-1]
      arm_name = settings[:arms_by_rows] ? row[column_offset - 3].to_s.strip : nil
      arm_description = settings[:arms_by_rows] ? row[column_offset - 2].to_s.strip : nil
      dirty_answers.each_with_index do |dirty_answer, column_index|
        @current_column = column_index + column_offset
        qrc_id = qrc_ids[column_index]
        clean_answer = dirty_answer.to_s.strip
        update_type2_section_record(extraction_id, sheet_name, qrc_id, clean_answer, arms_by_rows, arm_name, arm_description)
      end
    end
    @current_row, @current_column = nil
  end

  def process_results_sections
    RESULTS_SHEET_NAMES.each do |results_section_name|
      next unless @sheet_names.include?(results_section_name)
      puts "processing: #{results_section_name}"
      @current_sheet_name = results_section_name
      case results_section_name
      when 'Continuous - Desc. Statistics', 'Categorical - Desc. Statistics'
        process_results_q1_section(results_section_name)
      when 'Continuous - BAC Comparisons', 'Categorical - BAC Comparisons'
        process_results_q2_section(results_section_name)
      when 'WAC Comparisons'

      when 'NET Differences'

      end
      @current_sheet_name = nil
    end
  end

  def process_results_q1_section(sheet_name)
    sheet = get_sheet(sheet_name)
    column_offset = 18
    arm_interval = find_sub_section_intervals(sheet.row(1), 'Arm Name')
    measures = sheet.row(1)[column_offset..-1][2..(arm_interval ? arm_interval - 1 : -1)]

    sheet.each_with_index do |row, row_index|
      next if row_index == 0
      @current_row = row_index + 1

      oc_name, oc_desc = row[10, 11].map { |raw| raw.to_s.strip }
      pop_name, pop_desc = row[13, 14].map { |raw| raw.to_s.strip }
      tp_name, tp_unit = row[16, 17].map { |raw| raw.to_s.strip }
      all_dirty_arms = row[column_offset..-1]
      dirty_arms_groups = arm_interval ? all_dirty_arms.in_groups_of(arm_interval) : [all_dirty_arms]

      dirty_arms_groups.each do |dirty_arms_group|
        arm_name = dirty_arms_group[0].to_s.strip
        arm_desc = dirty_arms_group[1].to_s.strip
        dirty_arms_group[2..-1].each_with_index do |dirty_answer, column_index|
          @current_column = column_index + column_offset + 2
          msr_name = measures[column_index]
          clean_answer = dirty_answer.to_s.strip
          update_results_q1_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc)
        end
      end
    end
    @current_row, @current_column = nil
  end

  def process_results_q2_section(sheet_name)
    sheet = get_sheet(sheet_name)
    column_offset = 18
    comparison_interval = find_sub_section_intervals(sheet.row(1), 'Comparison Name')
    measures = sheet.row(1)[column_offset..-1][1..(comparison_interval ? comparison_interval - 1 : -1)]

    sheet.each_with_index do |row, row_index|
      next if row_index == 0
      @current_row = row_index + 1

      oc_name, oc_desc = row[10, 11].map { |raw| raw.to_s.strip }
      pop_name, pop_desc = row[13, 14].map { |raw| raw.to_s.strip }
      tp_name, tp_unit = row[16, 17].map { |raw| raw.to_s.strip }
      all_dirty_comparisons = row[column_offset..-1]
      dirty_comparisons_groups = comparison_interval ? all_dirty_comparisons.in_groups_of(comparison_interval) : [all_dirty_comparisons]

      dirty_comparisons_groups.each do |dirty_comparisons_group|
        next if dirty_comparisons_group[0].nil?
        comparison_id = dirty_comparisons_group[0].match(/(?<=\[ID: )(\d*)(?=\])/).try(:captures).try(:first).try(:to_i)

        dirty_comparisons_group[1..-1].each_with_index do |dirty_answer, column_index|
          @current_column = column_index + column_offset + 1
          msr_name = measures[column_index]
          clean_answer = dirty_answer.to_s.strip
          update_results_q2_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, comparison_id, oc_name, oc_desc)
        end
      end
    end
    @current_row, @current_column = nil
  end

  private

    def find_tps_comparisons_rssm(comparison_id, msr_name, tp_name, tp_unit, pop_name, pop_desc, oc_name, oc_desc)
      TpsComparisonsRssm.
        joins({
          result_statistic_sections_measure: :measure,
          timepoint: [:timepoint_name, extractions_extraction_forms_projects_sections_type1_row: [
            :population_name,
            { extractions_extraction_forms_projects_sections_type1: :type1 }]
          ]
        }).
        where(comparison_id: comparison_id).
        where("measures.name = ?", msr_name).
        where("timepoint_names.name = ? AND timepoint_names.unit = ?", tp_name, tp_unit).
        where("population_names.name = ? AND population_names.description = ?", pop_name, pop_desc).
        where("type1s.name = ? AND type1s.description = ?", oc_name, oc_desc).
        first
    end

    def find_sub_section_intervals(header_row, delimiter)
      section_2_index = header_row.index("#{delimiter} 2")
      section_2_index ? section_2_index - header_row.index("#{delimiter} 1") : nil
    end

    def find_tps_arms_rssm(msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc)
      TpsArmsRssm.
        joins({
          result_statistic_sections_measure: :measure,
          extractions_extraction_forms_projects_sections_type1: :type1,
          timepoint: [:timepoint_name, extractions_extraction_forms_projects_sections_type1_row: [
            :population_name,
            { extractions_extraction_forms_projects_sections_type1: :type1 }]
          ]
        }).
        where("measures.name = ?", msr_name).
        where("timepoint_names.name = ? AND timepoint_names.unit = ?", tp_name, tp_unit).
        where("population_names.name = ? AND population_names.description = ?", pop_name, pop_desc).
        where(extractions_extraction_forms_projects_sections_type1s: { type1s: { name: arm_name, description: arm_desc } }).
        where("type1s_extractions_extraction_forms_projects_sections_type1s.name = ? AND type1s_extractions_extraction_forms_projects_sections_type1s.description = ?", oc_name, oc_desc).
        first
    end

    def find_eefps_by_sheet_name_and_extraction_id(extraction_id, sheet_name)
      ExtractionsExtractionFormsProjectsSection.
        joins(extraction_forms_projects_section: :section).
        where(
          extraction_id: extraction_id,
          extraction_forms_projects_section: { sections: { name: sheet_name } }
        ).
        first
    end

    def find_qrcf_by_qrc_id(qrc_id)
      qrc = QuestionRowColumn.find(qrc_id)
      qrc.question_row_column_fields.first
    end

    def find_or_create_eefpsqrcf_by_eefps_and_qrcf(eefps, qrcf)
      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by!(
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: qrcf
      )
    end

    def find_or_create_eefpsqrcf_by_eefps_and_qrcf_and_arm_name(eefps, qrcf, arm_name, arm_description)
      type1 = Type1.find_by(name: arm_name, description: arm_description)
      eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1.
        find_by(type1: type1, extractions_extraction_forms_projects_section: eefps.link_to_type1)

      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by!(
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: qrcf,
        extractions_extraction_forms_projects_sections_type1: eefpst1
      )
    end

    def find_or_create_record_by_eefpsqrfc(eefpsqrcf)
      Record.find_or_create_by!(recordable: eefpsqrcf)
    end

    def update_results_q1_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc)
      tps_arms_rssm = find_tps_arms_rssm(msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc)

      if tps_arms_rssm && record = tps_arms_rssm.records.first
        record.update!(name: clean_answer) unless record.name == clean_answer
        @update_record[:tps_arms_rssm] += 1
      else
        @errors << {
          sheet_name: @current_sheet_name,
          row: @current_row,
          column: @current_column,
          error: "unable to locate tps_arms_rssm"
        }
      end
    end

    def update_results_q2_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, comparison_id, oc_name, oc_desc)
      tps_comparisons_rssm = find_tps_comparisons_rssm(comparison_id, msr_name, tp_name, tp_unit, pop_name, pop_desc, oc_name, oc_desc)

      if tps_comparisons_rssm && record = tps_comparisons_rssm.records.first
        record.update!(name: clean_answer) unless record.name == clean_answer
        @update_record[:tps_comparisons_rssm] += 1
      else
        @errors << {
          sheet_name: @current_sheet_name,
          row: @current_row,
          column: @current_column,
          error: "unable to locate tps_comparisons_rssm"
        }
      end
    end

    def update_type2_section_record(extraction_id, sheet_name, qrc_id, answer, arms_by_rows, arm_name, arm_description)
      eefps = find_eefps_by_sheet_name_and_extraction_id(extraction_id, sheet_name)
      qrcf = find_qrcf_by_qrc_id(qrc_id)
      eefpsqrcf = arms_by_rows ?
        find_or_create_eefpsqrcf_by_eefps_and_qrcf_and_arm_name(eefps, qrcf, arm_name, arm_description) :
          find_or_create_eefpsqrcf_by_eefps_and_qrcf(eefps, qrcf)

      case eefpsqrcf.question_row_column_field.question_row_column.question_row_column_type_id
      when 1, 2 # text, numeric
        update_record_type_1_2(eefpsqrcf, answer)
      when 5 # checkbox
        update_record_type_5(eefpsqrcf, answer)
      when 6, 7, 8 # dropdown, radio, select2_single
        update_record_type_6_7_8(eefpsqrcf, answer)
      when 9 # select2_multi
        update_record_type_9(eefpsqrcf, answer)
      else # 3 numeric_range, 4 scientific
        update_record_type_others(eefpsqrcf, answer)
      end
    end

    def update_record_type_1_2(eefpsqrcf, answer)
      record = find_or_create_record_by_eefpsqrfc(eefpsqrcf)
      if record.name != answer
        record.name = answer
        constraint_errors = record.check_constraints
        if constraint_errors.nil?
          record.save!
          @update_record[:type1and2] += 1
        else
          @errors << {
            sheet_name: @current_sheet_name,
            row: @current_row,
            column: @current_column,
            error: constraint_errors
          }
        end
      end
    end

    def update_record_type_5(eefpsqrcf, answer)
      answers = answer.split("\n")
      qrcqrco_ids = []
      answers.each do |answer|
        only_answer = answer.match(/(^.*)(?=\[Follow-up:)/).try(:captures).try(:first).try(:strip) || answer
        qrcqrco = eefpsqrcf.
          question_row_column_field.
          question_row_column.
          question_row_columns_question_row_column_options.
          find_by(name: only_answer)
        if qrcqrco.present?
          qrcqrco_ids << qrcqrco.id.to_s

          only_ff_answers = answer.
            match(/(?<=\[Follow\-up: )(.*)(?=\])/).
            try(:captures).
            try(:first).
            try { |captures| captures.split(",").map(&:strip)} || []
          if !only_ff_answers.empty? && qrcqrco.present?
            create_followup_fields(only_ff_answers, eefpsqrcf, qrcqrco)
          end
        else
          @errors << {
            sheet_name: @current_sheet_name,
            row: @current_row,
            column: @current_column,
            error: "cell contains invalid option: #{only_answer}"
          }
        end
      end
      record = find_or_create_record_by_eefpsqrfc(eefpsqrcf)

      qrcqrco_ids_string = qrcqrco_ids.to_json

      if record.name != qrcqrco_ids_string
        record.update!(name: qrcqrco_ids_string)
        @update_record[:type5] += 1
      end
    end

    def update_record_type_6_7_8(eefpsqrcf, answer)
      return if answer == '' || answer.nil?
      only_answer = answer.
        match(/(^.*)(?=\[Follow-up:)/).
        try(:captures).
        try(:first).
        try(:strip) || answer

      record = find_or_create_record_by_eefpsqrfc(eefpsqrcf)
      qrcqrco = eefpsqrcf.
        question_row_column_field.
        question_row_column.
        question_row_columns_question_row_column_options.
        find_by(name: only_answer)
      if qrcqrco.present? && qrcqrco.id.to_s != record.name
        record.update!(name: qrcqrco.id.to_s)
        @update_record[:type6and7and8] += 1
      elsif qrcqrco.nil?
        @errors << {
          sheet_name: @current_sheet_name,
          row: @current_row,
          column: @current_column,
          error: "cell contains invalid option: #{answer}"
        }
      end

      only_ff_answers = answer.
        match(/(?<=\[Follow\-up: )(.*)(?=\])/).
        try(:captures).
        try(:first).
        try { |captures| captures.split(",").
        map(&:strip)} || []
      qrct_id = eefpsqrcf.
        question_row_column_field.
        question_row_column.
        question_row_column_type_id
      if !only_ff_answers.empty? && qrcqrco.present? && (qrct_id == 6 || qrct_id == 7)
        create_followup_fields(only_ff_answers, eefpsqrcf, qrcqrco)
      end
    end

    def update_record_type_9(eefpsqrcf, answer)
      only_answers = answer.try { |asw| asw.split("\n").map { |a| a.try(:strip) } } || []
      only_answers.each do |only_answer|
        qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_by(
          question_row_column: eefpsqrcf.question_row_column_field.question_row_column,
          question_row_column_option_id: 1,
          name: only_answer
        )
        if qrcqrco.nil?
          @errors << {
            sheet_name: @current_sheet_name,
            row: @current_row,
            column: @current_column,
            error: "cell contains invalid option: #{only_answer}"
          }
          next
        end
        ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption.
          find_or_create_by!(
            question_row_columns_question_row_column_option: qrcqrco,
            extractions_extraction_forms_projects_sections_question_row_column_field: eefpsqrcf
          )
        @update_record[:type9] += 1
      end

      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption.
        joins(:question_row_columns_question_row_column_option).
        where(extractions_extraction_forms_projects_sections_question_row_column_field: eefpsqrcf).
        where.not(question_row_columns_question_row_column_options: { name: only_answers }).destroy_all
    end

    def update_record_type_others(eefpsqrcf, answer)
      previous_type1and2_count = @update_record[:type1and2]
      update_record_type_1_2(eefpsqrcf, answer)

      if previous_type1and2_count + 1 == @update_record[:type1and2]
        @update_record[:typeothers] += 1
        @update_record[:type1and2] = previous_type1and2_count
      end
    end

    def create_followup_fields(only_ff_answers, eefpsqrcf, qrcqrco)
      if qrcqrco.present? && qrcqrco.followup_field.present?
        only_ff_answers.each do |only_ff_answer|
          eefpsff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by!(
            followup_field: qrcqrco.followup_field,
            extractions_extraction_forms_projects_section: eefpsqrcf.extractions_extraction_forms_projects_section
          )
          record = Record.find_or_create_by!(recordable: eefpsff)
          record.update(name: only_ff_answer)
        end
      end
    end
end