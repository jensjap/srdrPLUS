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
      typeothers: 0
    }
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
    type2_sheet_names.each do |type2_sheet_name|
      if @sheet_names.include?(type2_sheet_name)
        puts "processing: #{type2_sheet_name}"
        @current_sheet_name = type2_sheet_name
        process_type2_section(type2_sheet_name)
        @current_sheet_name = nil
      end
    end
  end

  def process_type2_section(sheet_name)
    sheet = get_sheet(sheet_name)
    qrc_ids = sheet.row(1)[10..-1].map{ |header| header.split("\n")[1][/(?<=x)(.*?)(?=\])/m, 1] }

    sheet.each_with_index do |row, row_index|
      next if row_index == 0
      @current_row = row_index + 1
      extraction_id = row[0]
      dirty_answers = row[10..-1]
      dirty_answers.each_with_index do |dirty_answer, column_index|
        @current_column = column_index + 11
        qrc_id = qrc_ids[column_index]
        clean_answer = dirty_answer.to_s.strip
        update_records(extraction_id, sheet_name, qrc_id, clean_answer)
      end
    end
    @current_row, @current_column = nil
    puts "=" * 150
    puts "=" * 150
    p @update_record
    @errors.each do |e|
      pp e
    end
    puts "=" * 150
    puts "=" * 150
  end

  private

    def find_eefps_by_sheet_name_and_extraction_id(extraction_id, sheet_name)
      ExtractionsExtractionFormsProjectsSection.
        joins(extraction_forms_projects_section: :section).
        where(extraction_id: extraction_id, extraction_forms_projects_section: { sections: { name: sheet_name } }).first
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

    def find_or_create_record_by_eefpsqrfc(eefpsqrcf)
      Record.find_or_create_by!(recordable: eefpsqrcf)
    end

    def type2_sheet_names
      # ['Design Details', 'Arm Details', 'Sample Characteristics', 'Risk of Bias - RCTs', 'Risk of Bias - NRCSs', 'Risk of Bias - SGSs']
      ['Design Details']
    end

    def update_records(extraction_id, sheet_name, qrc_id, answer)
      eefps = find_eefps_by_sheet_name_and_extraction_id(extraction_id, sheet_name)
      qrcf = find_qrcf_by_qrc_id(qrc_id)
      eefpsqrcf = find_or_create_eefpsqrcf_by_eefps_and_qrcf(eefps, qrcf)

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
          record.update!
          @update_record[:type1and2] += 1
        else
          @errors << { sheet_name: @current_sheet_name, row: @current_row, column: @current_column, error: constraint_errors }
        end
      end
    end

    def update_record_type_5(eefpsqrcf, answer)
      answers = answer.split("\n")
      qrcqrco_ids = []
      answers.each do |answer|
        only_answer = answer.match(/(^.*)(?=\[Follow-up:)/).try(:captures).try(:first).try(:strip) || answer
        qrcqrco = eefpsqrcf.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(name: only_answer)
        if qrcqrco.present?
          qrcqrco_ids << qrcqrco.id.to_s

          only_ff_answers = answer.match(/(?<=\[Follow\-up: )(.*)(?=\])/).try(:captures).try(:first).try { |captures| captures.split(",").map(&:strip)} || []
          if !only_ff_answers.empty? && qrcqrco.present?
            create_followup_fields(only_ff_answers, eefpsqrcf, qrcqrco)
          end
        else
          @errors << { sheet_name: @current_sheet_name, row: @current_row, column: @current_column, error: "cell contains invalid option: #{only_answer}" }
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
      only_answer = answer.match(/(^.*)(?=\[Follow-up:)/).try(:captures).try(:first).try(:strip) || answer

      record = find_or_create_record_by_eefpsqrfc(eefpsqrcf)
      qrcqrco = eefpsqrcf.question_row_column_field.question_row_column.question_row_columns_question_row_column_options.find_by(name: only_answer)
      if qrcqrco.present? && qrcqrco.id.to_s != record.name
        record.update!(name: qrcqrco.id.to_s)
        @update_record[:type6and7and8] += 1
      elsif qrcqrco.nil?
        @errors << { sheet_name: @current_sheet_name, row: @current_row, column: @current_column, error: "cell contains invalid option: #{answer}" }
      end

      only_ff_answers = answer.match(/(?<=\[Follow\-up: )(.*)(?=\])/).try(:captures).try(:first).try { |captures| captures.split(",").map(&:strip)} || []
      question_row_column_type_id = eefpsqrcf.question_row_column_field.question_row_column.question_row_column_type_id
      if !only_ff_answers.empty? && qrcqrco.present? && (question_row_column_type_id == 6 || question_row_column_type_id == 7)
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
          @errors << { sheet_name: @current_sheet_name, row: @current_row, column: @current_column, error: "cell contains invalid option: #{only_answer}" }
          next
        end
        ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption.find_or_create_by!(
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