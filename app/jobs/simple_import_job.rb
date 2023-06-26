class SimpleImportJob < ApplicationJob
  DEFAULT_HEADERS = [
    'Extraction ID',
    'Consolidated',
    'Username',
    'Citation ID',
    'Citation Name',
    'RefMan',
    'other_reference',
    'PMID',
    'Authors',
    'Publication Date',
    'Key Questions'
  ]

  TYPE2_SHEET_NAMES = {
    'Design Details' => { column_offset: 12, arms_by_rows: false },
    'Arm Details' => { column_offset: 14, arms_by_rows: true },
    'Sample Characteristics' => { column_offset: 14, arms_by_rows: true },
    'Risk of Bias Assessment' => { column_offset: 12, arms_by_rows: false },
    'Risk of Bias - RCTs' => { column_offset: 12, arms_by_rows: false },
    'Risk of Bias - NRCSs' => { column_offset: 12, arms_by_rows: false },
    'Risk of Bias - SGSs' => { column_offset: 12, arms_by_rows: false }
  }

  RESULTS_SHEET_NAMES = [
    'Continuous - Desc. Statistics',
    'Categorical - Desc. Statistics',
    'Continuous - BAC Comparisons',
    'Categorical - BAC Comparisons',
    'WAC Comparisons',
    'NET Differences'
  ]

  attr_reader :xlsx, :sheet_names

  # Bool destructive, default: true.
  # By default we want to override any data that is being imported.
  # This allows removal of data, i.e. if there's data in the database
  # and the spreadsheet has an empty cell. In some special cases we do
  # not want this behavior. For example, if we want the import to be
  # additive only, i.e. no removal or change in existing data, only add
  # data when it is missing.
  def perform(imported_file_id, project_id, destructive: false)
    @destructive = destructive
    project = Project.find(project_id)
    @whitelisted_extraction_ids = project.extractions.map(&:id)
    imported_file = ImportedFile.find(imported_file_id)
    file = File.open("tmp/#{SecureRandom.uuid}.xlsx", 'wb')
    file.write(imported_file.content.download)

    @xlsx = Roo::Excelx.new(file.path)
    @sheet_names = @xlsx.sheets

    process_all

    ImportMailer.notify_import_completion(imported_file.id).deliver_later
  rescue StandardError => e
    ImportMailer.notify_import_failure(imported_file.id, e.message).deliver_later
  ensure
    file.close
    File.delete(file.path)
  end

  def logger
    @logger ||= Logger.new("#{Rails.root}/log/simple_import_job.log")
    @logger.level = 1
    @logger
  end

  def display_process(sheet_name)
    start = Time.new
    logger.info("processing: #{sheet_name}")
    @current_sheet_name = sheet_name
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

    yield

    logger.info(@update_record)
    logger.info(@errors)
    logger.info(@errors.count)

    @current_sheet_name = nil
    logger.info("Elapsed: #{Time.new - start}")
  end

  def process_all
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

      display_process(type2_sheet_name) do
        process_type2_section(type2_sheet_name, settings)
      end
    end
  end

  def process_type2_section(sheet_name, settings)
    sheet = get_sheet(sheet_name)
    column_offset = settings[:column_offset]
    arms_by_rows = settings[:arms_by_rows]

    qrc_ids = sheet
              .row(1)[(column_offset - 1)..-1]
              .map { |header| header[/\[Field\sID:\s*\d+x(\d+)\]\z/, 1] }

    sheet.each_with_index do |row, row_index|
      next if row_index == 0

      @current_row = row_index + 1
      extraction_id = row[0].to_i
      next unless @whitelisted_extraction_ids.include?(extraction_id)

      dirty_answers = row[(column_offset - 1)..-1]
      arm_name = settings[:arms_by_rows] ? row[column_offset - 3].to_s.dup : nil
      arm_description = settings[:arms_by_rows] ? row[column_offset - 2].to_s.dup : nil
      dirty_answers.each_with_index do |dirty_answer, column_index|
        @current_column = column_index + column_offset
        qrc_id = qrc_ids[column_index]
        clean_answer = dirty_answer.to_s.dup
        update_type2_section_record(
          extraction_id,
          sheet_name,
          qrc_id,
          clean_answer,
          arms_by_rows,
          arm_name,
          arm_description
        )
      end
    end
    @current_row, @current_column = nil
  end

  def process_results_sections
    RESULTS_SHEET_NAMES.each do |results_section_name|
      next unless @sheet_names.include?(results_section_name)

      @current_sheet_name = results_section_name
      display_process(results_section_name) do
        case results_section_name
        when 'Continuous - Desc. Statistics', 'Categorical - Desc. Statistics'
          process_results_q1_section(results_section_name)
        when 'Continuous - BAC Comparisons', 'Categorical - BAC Comparisons'
          process_results_q2_section(results_section_name)
        when 'WAC Comparisons'
          process_results_q3_section(results_section_name)
        when 'NET Differences'
          process_results_q4_section(results_section_name)
        end
      end
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

      oc_name, oc_desc = row[10, 11].map { |raw| raw.to_s.dup }
      pop_name, pop_desc = row[13, 14].map { |raw| raw.to_s.dup }
      tp_name, tp_unit = row[16, 17].map { |raw| raw.to_s.dup }
      all_dirty_arms = row[column_offset..-1]
      dirty_arms_groups = arm_interval ? all_dirty_arms.in_groups_of(arm_interval) : [all_dirty_arms]
      extraction_id = row[0].to_i
      next unless @whitelisted_extraction_ids.include?(extraction_id)

      dirty_arms_groups.each_with_index do |dirty_arms_group, group_index|
        arm_name = dirty_arms_group[0].to_s.dup
        arm_desc = dirty_arms_group[1].to_s.dup
        dirty_arms_group[2..-1].each_with_index do |dirty_answer, column_index|
          next if dirty_arms_group[0].nil?

          @current_column = column_offset + (group_index * arm_interval.to_i) + column_index + 3
          msr_name = measures[column_index]
          clean_answer = dirty_answer.to_s.dup
          update_results_q1_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name,
                                           arm_desc, oc_name, oc_desc, extraction_id)
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

      oc_name, oc_desc = row[10, 11].map { |raw| raw.to_s.dup }
      pop_name, pop_desc = row[13, 14].map { |raw| raw.to_s.dup }
      tp_name, tp_unit = row[16, 17].map { |raw| raw.to_s.dup }
      all_dirty_comparisons = row[column_offset..-1]
      dirty_comparisons_groups = comparison_interval ? all_dirty_comparisons.in_groups_of(comparison_interval) : [all_dirty_comparisons]

      dirty_comparisons_groups.each_with_index do |dirty_comparisons_group, group_index|
        next if dirty_comparisons_group[0].nil?

        comparison_id = dirty_comparisons_group[0].match(/(?<=\[ID: )(\d*)(?=\])/).try(:captures).try(:first).try(:to_i)

        dirty_comparisons_group[1..-1].each_with_index do |dirty_answer, column_index|
          @current_column = column_offset + (group_index * comparison_interval.to_i) + column_index + 2
          msr_name = measures[column_index]
          clean_answer = dirty_answer.to_s.dup
          update_results_q2_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, comparison_id,
                                           oc_name, oc_desc)
        end
      end
    end
    @current_row, @current_column = nil
  end

  def process_results_q3_section(sheet_name)
    sheet = get_sheet(sheet_name)
    column_offset = 17
    arm_interval = find_sub_section_intervals(sheet.row(1), 'Arm Name')
    measures = sheet.row(1)[column_offset..-1][2..(arm_interval ? arm_interval - 1 : -1)]

    sheet.each_with_index do |row, row_index|
      next if row_index == 0

      @current_row = row_index + 1

      oc_name, oc_desc = row[10, 11].map { |raw| raw.to_s.dup }
      pop_name, pop_desc = row[13, 14].map { |raw| raw.to_s.dup }
      comparison_id = row[16].match(/(?<=\[ID: )(\d*)(?=\])/).try(:captures).try(:first).try(:to_i)
      all_dirty_arms = row[column_offset..-1]
      dirty_arms_groups = arm_interval ? all_dirty_arms.in_groups_of(arm_interval) : [all_dirty_arms]
      extraction_id = row[0].to_i
      next unless @whitelisted_extraction_ids.include?(extraction_id)

      dirty_arms_groups.each_with_index do |dirty_arms_group, group_index|
        next if dirty_arms_group[0].nil?

        arm_name = dirty_arms_group[0].to_s.dup
        arm_desc = dirty_arms_group[1].to_s.dup
        dirty_arms_group[2..-1].each_with_index do |dirty_answer, column_index|
          @current_column = column_offset + (group_index * arm_interval.to_i) + column_index + 3
          msr_name = measures[column_index]
          clean_answer = dirty_answer.to_s.dup
          update_results_q3_section_record(clean_answer, msr_name, comparison_id, arm_name, arm_desc, extraction_id,
                                           pop_name, pop_desc, oc_name, oc_desc)
        end
      end
    end
    @current_row, @current_column = nil
  end

  def process_results_q4_section(sheet_name)
    sheet = get_sheet(sheet_name)
    column_offset = 17
    comparison_interval = find_sub_section_intervals(sheet.row(1), 'Comparison Name')
    measures = sheet.row(1)[column_offset..-1][1..(comparison_interval ? comparison_interval - 1 : -1)]
    sheet.each_with_index do |row, row_index|
      next if row_index == 0

      @current_row = row_index + 1

      all_dirty_comparisons = row[column_offset..-1]
      dirty_comparisons_groups = comparison_interval ? all_dirty_comparisons.in_groups_of(comparison_interval) : [all_dirty_comparisons]
      wac_id = row[column_offset - 1].match(/(?<=\[ID: )(\d*)(?=\])/).try(:captures).try(:first).try(:to_i)
      oc_name, oc_desc = row[10, 11].map { |raw| raw.to_s.dup }
      pop_name, pop_desc = row[13, 14].map { |raw| raw.to_s.dup }

      dirty_comparisons_groups.each_with_index do |dirty_comparisons_group, group_index|
        next if dirty_comparisons_group[0].nil?

        bac_id = dirty_comparisons_group[0].match(/(?<=\[ID: )(\d*)(?=\])/).try(:captures).try(:first).try(:to_i)

        dirty_comparisons_group[1..-1].each_with_index do |dirty_answer, column_index|
          @current_column = column_offset + (group_index * comparison_interval.to_i) + column_index + 2
          msr_name = measures[column_index]
          clean_answer = dirty_answer.to_s.dup
          update_results_q4_section_record(clean_answer, msr_name, wac_id, bac_id, pop_name, pop_desc, oc_name, oc_desc)
        end
      end
    end
    @current_row, @current_column = nil
  end

  private

  def find_tps_arms_rssm(msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc, extraction_id)
    eefpst1rc = ExtractionsExtractionFormsProjectsSectionsType1RowColumn
                .joins(
                  :timepoint_name,
                  extractions_extraction_forms_projects_sections_type1_row: [
                    :population_name,
                    { extractions_extraction_forms_projects_sections_type1: :type1 }
                  ]
                )
                .where('population_names.name = ? AND population_names.description = ?', pop_name, pop_desc)
                .where('type1s.name = ? AND type1s.description = ?', oc_name, oc_desc)
                .where('timepoint_names.name = ? AND timepoint_names.unit = ?', tp_name, tp_unit)
                .first

    rsst = ResultStatisticSectionType.find_by(name: 'Descriptive Statistics')
    rss = ResultStatisticSection.find_or_create_by!(
      result_statistic_section_type: rsst,
      population: eefpst1rc.extractions_extraction_forms_projects_sections_type1_row
    )
    measure = Measure.find_by(name: msr_name)
    rssm = ResultStatisticSectionsMeasure.find_or_create_by!(
      result_statistic_section: rss,
      measure:
    )
    eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1
              .joins(:type1)
              .joins(extractions_extraction_forms_projects_section: :extraction)
              .where('type1s.name = ? AND type1s.description = ?', arm_name, arm_desc)
              .where('extractions.id = ?', extraction_id)
              .first

    TpsArmsRssm.find_or_create_by!(
      extractions_extraction_forms_projects_sections_type1: eefpst1,
      result_statistic_sections_measure: rssm,
      timepoint: eefpst1rc
    )
  end

  def find_tps_comparisons_rssm(comparison_id, msr_name, tp_name, tp_unit, pop_name, pop_desc, oc_name, oc_desc)
    eefpst1rc = ExtractionsExtractionFormsProjectsSectionsType1RowColumn
                .joins(
                  :timepoint_name,
                  extractions_extraction_forms_projects_sections_type1_row: [
                    :population_name,
                    { extractions_extraction_forms_projects_sections_type1: :type1 }
                  ]
                )
                .where('population_names.name = ? AND population_names.description = ?', pop_name, pop_desc)
                .where('type1s.name = ? AND type1s.description = ?', oc_name, oc_desc)
                .where('timepoint_names.name = ? AND timepoint_names.unit = ?', tp_name, tp_unit)
                .first
    rsst = ResultStatisticSectionType.find_by(name: 'Between Arm Comparisons')
    rss = ResultStatisticSection.find_or_create_by!(
      result_statistic_section_type: rsst,
      population: eefpst1rc.extractions_extraction_forms_projects_sections_type1_row
    )
    measure = Measure.find_by(name: msr_name)
    rssm = ResultStatisticSectionsMeasure.find_or_create_by!(
      result_statistic_section: rss,
      measure:
    )
    TpsComparisonsRssm.find_or_create_by!(
      comparison_id:,
      result_statistic_sections_measure: rssm,
      timepoint: eefpst1rc
    )
  end

  def find_comparisons_arms_rssm(comparison_id, msr_name, arm_name, arm_desc, pop_name, pop_desc, oc_name, oc_desc, extraction_id)
    eefpst1r = ExtractionsExtractionFormsProjectsSectionsType1Row
               .joins(
                 :population_name,
                 { extractions_extraction_forms_projects_sections_type1: :type1 }
               )
               .where('population_names.name = ? AND population_names.description = ?', pop_name, pop_desc)
               .where('type1s.name = ? AND type1s.description = ?', oc_name, oc_desc)
               .first
    eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1
              .joins(:type1)
              .joins(extractions_extraction_forms_projects_section: :extraction)
              .where('type1s.name = ? AND type1s.description = ?', arm_name, arm_desc)
              .where('extractions.id = ?', extraction_id)
              .first

    rsst = ResultStatisticSectionType.find_by(name: 'Within Arm Comparisons')
    rss = ResultStatisticSection.find_or_create_by!(
      result_statistic_section_type: rsst,
      population: eefpst1r
    )
    measure = Measure.find_by(name: msr_name)
    rssm = ResultStatisticSectionsMeasure.find_or_create_by!(
      result_statistic_section: rss,
      measure:
    )

    ComparisonsArmsRssm.find_or_create_by!(
      comparison_id:,
      extractions_extraction_forms_projects_sections_type1: eefpst1,
      result_statistic_sections_measure: rssm
    )
  end

  def find_wacs_bacs_rssm(wac_id, bac_id, msr_name, pop_name, pop_desc, oc_name, oc_desc)
    eefpst1r = ExtractionsExtractionFormsProjectsSectionsType1Row
               .joins(
                 :population_name,
                 { extractions_extraction_forms_projects_sections_type1: :type1 }
               )
               .where('population_names.name = ? AND population_names.description = ?', pop_name, pop_desc)
               .where('type1s.name = ? AND type1s.description = ?', oc_name, oc_desc)
               .first
    rsst = ResultStatisticSectionType.find_by(name: 'Net Change')
    rss = ResultStatisticSection.find_or_create_by!(
      result_statistic_section_type: rsst,
      population: eefpst1r
    )
    measure = Measure.find_by(name: msr_name)
    rssm = ResultStatisticSectionsMeasure.find_or_create_by!(
      result_statistic_section: rss,
      measure:
    )
    WacsBacsRssm.find_or_create_by!(
      wac_id:,
      bac_id:,
      result_statistic_sections_measure: rssm
    )
  end

  def find_eefps_by_sheet_name_and_extraction_id(extraction_id, sheet_name)
    ExtractionsExtractionFormsProjectsSection
      .joins(extraction_forms_projects_section: :section)
      .where(
        extraction_id:,
        extraction_forms_projects_section: { sections: { name: sheet_name } }
      )
      .first
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
    eefpst1 = ExtractionsExtractionFormsProjectsSectionsType1
              .find_by(type1:, extractions_extraction_forms_projects_section: eefps.link_to_type1)

    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by!(
      extractions_extraction_forms_projects_section: eefps,
      question_row_column_field: qrcf,
      extractions_extraction_forms_projects_sections_type1: eefpst1
    )
  end

  def find_or_create_record_by_eefpsqrfc(eefpsqrcf)
    Record.find_or_create_by!(recordable: eefpsqrcf)
  end

  def update_results_q1_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc, extraction_id)
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && clean_answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    tps_arms_rssm = find_tps_arms_rssm(msr_name, tp_name, tp_unit, pop_name, pop_desc, arm_name, arm_desc, oc_name, oc_desc, extraction_id)
    record = Record.find_or_create_by!(recordable: tps_arms_rssm)
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{clean_answer}") if @destructive.blank?
    unless record.name == clean_answer
      record.update!(name: clean_answer)
      @update_record[:tps_arms_rssm] += 1
    end
  rescue StandardError => e
    @errors << {
      sheet_name: @current_sheet_name,
      row: @current_row,
      column: @current_column,
      error: e.to_s
    }
  end

  def update_results_q2_section_record(clean_answer, msr_name, tp_name, tp_unit, pop_name, pop_desc, comparison_id, oc_name, oc_desc)
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && clean_answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    tps_comparisons_rssm = find_tps_comparisons_rssm(comparison_id, msr_name, tp_name, tp_unit, pop_name, pop_desc, oc_name, oc_desc)
    record = Record.find_or_create_by!(recordable: tps_comparisons_rssm)
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{clean_answer}") if @destructive.blank?
    unless record.name == clean_answer
      record.update!(name: clean_answer)
      @update_record[:tps_comparisons_rssm] += 1
    end
  rescue StandardError => e
    @errors << {
      sheet_name: @current_sheet_name,
      row: @current_row,
      column: @current_column,
      error: e.to_s
    }
  end

  def update_results_q3_section_record(clean_answer, msr_name, comparison_id, arm_name, arm_desc, extraction_id, pop_name, pop_desc, oc_name, oc_desc)
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && clean_answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    comparisons_arms_rssm = find_comparisons_arms_rssm(comparison_id, msr_name, arm_name, arm_desc, pop_name, pop_desc, oc_name, oc_desc, extraction_id)
    record = Record.find_or_create_by!(recordable: comparisons_arms_rssm)
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{clean_answer}") if @destructive.blank?
    unless record.name == clean_answer
      record.update!(name: clean_answer)
      @update_record[:comparisons_arms_rssm] += 1
    end
  rescue StandardError => e
    @errors << {
      sheet_name: @current_sheet_name,
      row: @current_row,
      column: @current_column,
      error: e.to_s
    }
  end

  def update_results_q4_section_record(clean_answer, msr_name, wac_id, bac_id, pop_name, pop_desc, oc_name, oc_desc)
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && clean_answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    wacs_bacs_rssm = find_wacs_bacs_rssm(wac_id, bac_id, msr_name, pop_name, pop_desc, oc_name, oc_desc)
    record = Record.find_or_create_by!(recordable: wacs_bacs_rssm)
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{clean_answer}") if @destructive.blank?
    unless record.name == clean_answer
      record.update!(name: clean_answer)
      @update_record[:wacs_bacs_rssm] += 1
    end
  rescue StandardError => e
    @errors << {
      sheet_name: @current_sheet_name,
      row: @current_row,
      column: @current_column,
      error: e.to_s
    }
  end

  def update_type2_section_record(extraction_id, sheet_name, qrc_id, answer, arms_by_rows, arm_name, arm_description)
    eefps = find_eefps_by_sheet_name_and_extraction_id(extraction_id, sheet_name)
    qrcf = find_qrcf_by_qrc_id(qrc_id)
    eefpsqrcf = if arms_by_rows
                  find_or_create_eefpsqrcf_by_eefps_and_qrcf_and_arm_name(eefps, qrcf, arm_name, arm_description)
                else
                  find_or_create_eefpsqrcf_by_eefps_and_qrcf(eefps, qrcf)
                end

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
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    record = find_or_create_record_by_eefpsqrfc(eefpsqrcf)
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{answer}") if @destructive.blank?
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
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    answers = answer.split("\n")
    qrcqrco_ids = []
    answers.each do |answer|
      only_answer = answer.match(/(^.*)(?=\[Follow-up:)/).try(:captures).try(:first).try(:dup) || answer
      qrcqrco = eefpsqrcf
                .question_row_column_field
                .question_row_column
                .question_row_columns_question_row_column_options
                .find_by(name: only_answer)
      if qrcqrco.present?
        qrcqrco_ids << qrcqrco.id.to_s

        only_ff_answers = answer
                          .match(/(?<=\[Follow-up: )(.*)(?=\])/)
                          .try(:captures)
                          .try(:first)
                          .try { |captures| captures.split(',').map(&:dup) } || []
        create_followup_fields(only_ff_answers, eefpsqrcf, qrcqrco) if !only_ff_answers.empty? && qrcqrco.present?
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
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{answer}") if @destructive.blank?
    qrcqrco_ids_string = qrcqrco_ids.to_json

    if record.name != qrcqrco_ids_string
      record.update!(name: qrcqrco_ids_string)
      @update_record[:type5] += 1
    end
  end

  def update_record_type_6_7_8(eefpsqrcf, answer)
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    return if answer == '' || answer.nil?

    only_answer = answer
                  .match(/(^.*)(?=\[Follow-up:)/)
                  .try(:captures)
                  .try(:first)
                  .try(:dup) || answer

    record = find_or_create_record_by_eefpsqrfc(eefpsqrcf)
    # Prevent existing data from being changed when @destructive: false.
    if @destructive.blank? && record.name.present?
      logger.debug('Destructive: false. Existing data found...skipping cell.')
      return
    end

    logger.info("Destructive: false but no data detected. Inserting missing data: #{answer}") if @destructive.blank?
    qrcqrco = eefpsqrcf
              .question_row_column_field
              .question_row_column
              .question_row_columns_question_row_column_options
              .find_by(name: only_answer)
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

    only_ff_answers = answer
                      .match(/(?<=\[Follow-up: )(.*)(?=\])/)
                      .try(:captures)
                      .try(:first)
                      .try do |captures|
      captures.split(',')
              .map(&:dup)
    end || []
    qrct_id = eefpsqrcf
              .question_row_column_field
              .question_row_column
              .question_row_column_type_id
    if !only_ff_answers.empty? && qrcqrco.present? && [6, 7].include?(qrct_id)
      create_followup_fields(only_ff_answers, eefpsqrcf, qrcqrco)
    end
  end

  def update_record_type_9(eefpsqrcf, answer)
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && answer.blank?
      logger.debug('Destructive: false. Answer is empty...skipping cell.')
      return
    end

    only_answers = answer.try { |asw| asw.split("\n").map { |a| a.try(:dup) } } || []
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
      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption
        .find_or_create_by!(
          question_row_columns_question_row_column_option: qrcqrco,
          extractions_extraction_forms_projects_sections_question_row_column_field: eefpsqrcf
        )
      @update_record[:type9] += 1
    end

    # If @destructive: false, return.
    return unless @destructive

    logger.debug('Destructive: false. No need to remove select2-multi selections.') if @destructive.blank?
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption
      .joins(:question_row_columns_question_row_column_option)
      .where(extractions_extraction_forms_projects_sections_question_row_column_field: eefpsqrcf)
      .where.not(question_row_columns_question_row_column_options: { name: only_answers }).destroy_all
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
    # Prevent empty cell from wiping existing data when @destructive: false.
    if @destructive.blank? && only_ff_answers.blank?
      logger.debug('Destructive: false. Answer is empty...skipping ff_answers.')
      return
    end

    if qrcqrco.present? && qrcqrco.followup_field.present?
      only_ff_answers.each do |only_ff_answer|
        eefpsff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by!(
          followup_field: qrcqrco.followup_field,
          extractions_extraction_forms_projects_section: eefpsqrcf.extractions_extraction_forms_projects_section
        )
        record = Record.find_or_create_by!(recordable: eefpsff)
        # Prevent existing data from being changed when @destructive: false.
        if @destructive.blank? && record.name.present?
          logger.debug('Destructive: false. Existing data found...skipping ff_answer.')
          next
        end
        if @destructive.blank? && only_ff_answer.blank?
          logger.debug('Destructive: false. Answer is empty...skipping ff_answer.')
          return
        end

        logger.info("Destructive: false but no data detected. Inserting missing data: #{only_ff_answer}") if @destructive.blank? && only_ff_answer.present?
        record.update!(name: only_ff_answer)
      end
    end
  end

  def find_sub_section_intervals(header_row, delimiter)
    section_2_index = header_row.index("#{delimiter} 2")
    section_2_index ? section_2_index - header_row.index("#{delimiter} 1") : nil
  end
end
