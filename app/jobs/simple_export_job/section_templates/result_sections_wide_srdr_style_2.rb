require 'simple_export_job/sheet_info'

module ResultSectionsWideSRDRStyle2
  def build_result_sections_wide_srdr_style_2(kq_ids=[], print_empty_row=false)
    @project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|

        # If this is a results section then we proceed.
        next unless efps.extraction_forms_projects_section_type_id == 3

        # Create SheetInfo object for results sections.
        @sheet_info = SheetInfo.new(@project)
        @sheet_info.populate!(:results, kq_ids, efp, efps)

        # There are two types of Extractions: Standard and Diagnostic Test
        case efps.extraction_forms_project.extraction_forms_project_type_id
        when 1
          _export_standard_ef_results

        when 2
          _export_diagnostic_test_ef_results

        else
          raise "ResultSectionsWideSRDRStyle2: Unknown ExtractionFormsProjectType"

        end  # case efps.extraction_forms_projects_section_type_id
      end  # END efp.extraction_forms_projects_sections.each do |efps|
    end  # END @project.extraction_forms_projects.each do |efp|
  end

  def _export_standard_ef_results
    # Create and name worksheets.
    ws_descriptive_statistics_continuous_outcomes  = @package.workbook.add_worksheet(name: "Continuous - Desc. Statistics")
    ws_descriptive_statistics_categorical_outcomes = @package.workbook.add_worksheet(name: "Categorical - Desc. Statistics")
    ws_bac_statistics_continuous_outcomes          = @package.workbook.add_worksheet(name: "Continuous - BAC Comparisons")
    ws_bac_statistics_categorical_outcomes         = @package.workbook.add_worksheet(name: "Categorical - BAC Comparisons")
    ws_wac_statistics                              = @package.workbook.add_worksheet(name: "WAC Comparisons")
    ws_net_statistics                              = @package.workbook.add_worksheet(name: "NET Differences")

    # Start printing rows to the sheets. First the basic headers:
    #   Categorical populations only apply to Desc. Statistics and BAC Comparisons.
    #   WAC and Net Differences only apply to Continuous.
    desc_cont_header = ws_descriptive_statistics_continuous_outcomes.add_row(
      @sheet_info.header_info +
      ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
      @sheet_info.data_headers(1, "Continuous", "Arm")
    )
    desc_cat_header = ws_descriptive_statistics_categorical_outcomes.add_row(
      @sheet_info.header_info +
      ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
      @sheet_info.data_headers(1, "Categorical", "Arm")
    )
    bac_cont_header = ws_bac_statistics_continuous_outcomes.add_row(
      @sheet_info.header_info +
      ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
      @sheet_info.data_headers(2, "Continuous", "Comparison")
    )
    bac_cat_header = ws_bac_statistics_categorical_outcomes.add_row(
      @sheet_info.header_info +
      ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
      @sheet_info.data_headers(2, "Categorical", "Comparison")
    )
    wac_header = ws_wac_statistics.add_row(
      @sheet_info.header_info +
      ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'WAC Comparator'] +
      @sheet_info.data_headers(3, "Continuous", "Arm")
    )
    net_header = ws_net_statistics.add_row(
      @sheet_info.header_info +
      ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'WAC Comparator'] +
      @sheet_info.data_headers(4, "Continuous", "Comparison")
    )

    @sheet_info.extractions.each do |e_key, extraction|
      # Column refers to the columns in the results quadrants.
      #
      #   Desc statistics: (Timepoints x Arms): column => Arms
      #   BAC comparisons: (Timepoints x BAC) : column => BAC
      #   WAC comparisons: (   WAC     x Arms): column => Arms
      #   NET comparisons: (   WAC     x BAC) : column => BAC

      extraction[:rss_columns].each do |rss_type_id, outcomes|
        outcomes.each do |outcome_id, populations|
          populations.each do |population_id, rss_rows|
            rss_rows.each do |row_id, rss_cols|
              new_row = []
              new_row << extraction[:extraction_info][:extraction_id]
              new_row << extraction[:extraction_info][:consolidated]
              new_row << extraction[:extraction_info][:username]
              new_row << extraction[:extraction_info][:citation_id]
              new_row << extraction[:extraction_info][:citation_name]
              new_row << extraction[:extraction_info][:refman]
              new_row << extraction[:extraction_info][:pmid]
              new_row << extraction[:extraction_info][:authors]
              new_row << extraction[:extraction_info][:publication_date]
              new_row << extraction[:extraction_info][:kq_selection]

              # Pick a representative rssm just for information.
              rssm = rss_cols.values[0][0]

              case rss_type_id
              when 1
                new_row << rssm[:outcome_name]
                new_row << rssm[:outcome_description]
                new_row << rssm[:outcome_type]
                new_row << rssm[:population_name]
                new_row << md5_digest(extraction, rssm)
                new_row << rssm[:row_name]
                new_row << rssm[:row_unit]

                if rssm[:outcome_type].eql? "Continuous"
                  new_row.concat(build_data_row(rss_cols, desc_cont_header))
                  ws_descriptive_statistics_continuous_outcomes.add_row(new_row)

                elsif rssm[:outcome_type].eql? "Categorical"
                  new_row.concat(build_data_row(rss_cols, desc_cat_header))
                  ws_descriptive_statistics_categorical_outcomes.add_row(new_row)

                else
                  next

                end

              when 2
                new_row << rssm[:outcome_name]
                new_row << rssm[:outcome_description]
                new_row << rssm[:outcome_type]
                new_row << rssm[:population_name]
                new_row << md5_digest(extraction, rssm)
                new_row << rssm[:row_name]
                new_row << rssm[:row_unit]

                if rssm[:outcome_type].eql? "Continuous"
                  new_row.concat(build_data_row(rss_cols, bac_cont_header))
                  ws_bac_statistics_continuous_outcomes.add_row(new_row)

                elsif rssm[:outcome_type].eql? "Categorical"
                  new_row.concat(build_data_row(rss_cols, bac_cat_header))
                  ws_bac_statistics_categorical_outcomes.add_row(new_row)

                else
                  next

                end

              when 3
                new_row << rssm[:outcome_name]
                new_row << rssm[:outcome_description]
                new_row << rssm[:outcome_type]
                new_row << rssm[:population_name]
                new_row << md5_digest(extraction, rssm)
                new_row << rssm[:row_name]

                if rssm[:outcome_type].eql? "Continuous"
                  new_row.concat(build_data_row(rss_cols, wac_header))
                  ws_wac_statistics.add_row(new_row)

                else
                  # According to Ian, WAC does not make sense for Categorical

                end

              when 4
                new_row << rssm[:outcome_name]
                new_row << rssm[:outcome_description]
                new_row << rssm[:outcome_type]
                new_row << rssm[:population_name]
                new_row << md5_digest(extraction, rssm)
                new_row << rssm[:row_name]

                if rssm[:outcome_type].eql? "Continuous"
                  new_row.concat(build_data_row(rss_cols, net_header))
                  ws_net_statistics.add_row(new_row)

                else
                  # According to Ian, WAC does not make sense for Categorical

                end

              end  # case rss_type_id
            end  # rss_rows.each do |row_id, rss_cols|
          end  # populations.each do |population_id, rss_rows|
        end  # outcomes.each do |outcome_id, populations|
      end  # extraction[:rss_columns].each do |rss_type_id, outcomes|
    end  # @sheet_info.extractions.each do |e_key, extraction|

    # Style header row.
    desc_cont_header.style = @highlight
    desc_cat_header.style  = @highlight
    bac_cont_header.style  = @highlight
    bac_cat_header.style   = @highlight
    wac_header.style  = @highlight
    net_header.style  = @highlight

    # Set styles for each worksheet.
    style_dscoo1, style_dscoo2, style_dscoo3, style_dscoo4 = set_ws_styles(ws_descriptive_statistics_continuous_outcomes)
    style_dscao1, style_dscao2, style_dscao3, style_dscao4 = set_ws_styles(ws_descriptive_statistics_categorical_outcomes)
    style_bscoo1, style_bscoo2, style_bscoo3, style_bscoo4 = set_ws_styles(ws_bac_statistics_continuous_outcomes)
    style_bscao1, style_bscao2, style_bscao3, style_bscao4 = set_ws_styles(ws_bac_statistics_categorical_outcomes)
    style_wacst1, style_wacst2, style_wacst3, style_wacst4 = set_ws_styles(ws_wac_statistics)
    style_netst1, style_netst2, style_netst3, style_netst4 = set_ws_styles(ws_net_statistics)

    style_data_columns_in_worksheet(
      @sheet_info.data_header_hash.try(:[], :max_col).try(:[], 1).try(:[], "Continuous").try(:[], :no_of_measures),
      ws_descriptive_statistics_continuous_outcomes,
      style_dscoo1, style_dscoo2, style_dscoo3, style_dscoo4)
    style_data_columns_in_worksheet(
      @sheet_info.data_header_hash.try(:[], :max_col).try(:[], 1).try(:[], "Categorical").try(:[], :no_of_measures),
      ws_descriptive_statistics_categorical_outcomes,
      style_dscao1, style_dscao2, style_dscao3, style_dscao4)
    style_data_columns_in_worksheet(
      @sheet_info.data_header_hash.try(:[], :max_col).try(:[], 2).try(:[], "Continuous").try(:[], :no_of_measures),
      ws_bac_statistics_continuous_outcomes,
      style_bscoo1, style_bscoo2, style_bscoo3, style_bscoo4)
    style_data_columns_in_worksheet(
      @sheet_info.data_header_hash.try(:[], :max_col).try(:[], 2).try(:[], "Categorical").try(:[], :no_of_measures),
      ws_bac_statistics_categorical_outcomes,
      style_bscao1, style_bscao2, style_bscao3, style_bscao4)
    style_data_columns_in_worksheet(
      @sheet_info.data_header_hash.try(:[], :max_col).try(:[], 3).try(:[], "Continuous").try(:[], :no_of_measures),
      ws_wac_statistics,
      style_wacst1, style_wacst2, style_wacst3, style_wacst4)
    style_data_columns_in_worksheet(
      @sheet_info.data_header_hash.try(:[], :max_col).try(:[], 4).try(:[], "Continuous").try(:[], :no_of_measures),
      ws_net_statistics,
      style_netst1, style_netst2, style_netst3, style_netst4)
  end  # def _export_standard_ef_results

  def build_data_row(rss_cols, header)
    # data_row is just the portion of the row that is below the headers:
    # ['Arm Name 1', 'Arm Description 1', 'Measure 1', 'Measure 2', 'Arm Name 2', 'Arm Description 2', 'Measure 1', ...]
    data_row = []

    # We generalize the naming of Arm or Comparison by calling it rss column or just col.
    # cnt_col is the number of rss columns
    cnt_col = rss_cols.length
    found, idx_start_of_data = find_index_of_cell_with_value(header)
    length_of_data_header = header.length - (idx_start_of_data)
    length_of_identifiers = header.length - length_of_data_header

    rss_cols.each_with_index do |col, idx|
      col_id = col[0]
      col[1].each do |rssm|
        # Fetch the length of each of the data rss column groups.
        length_of_each_col_group = @sheet_info.data_header_hash.try(:[], :max_col).try(:[], rssm[:result_statistic_section_type_id]).try(:[], rssm[:outcome_type]).try(:[], :no_of_measures)

        # Note...this will retrieve the first occurence...we will add multiples of col-group size to find the correct location.
        found, m_idx = find_index_of_cell_with_value(header, rssm[:measure_name])
        if found
          data_row[(m_idx - length_of_identifiers) + (length_of_each_col_group*idx)] = rssm[:rssm_values]

          # For rss types 1 and 3 we need to add Arm Description
          if [1, 3].include? rssm[:result_statistic_section_type_id]
            data_row[0 + (length_of_each_col_group*idx)] = rssm[:col_name]
            data_row[1 + (length_of_each_col_group*idx)] = rssm[:col_description]

          else
            data_row[0 + (length_of_each_col_group*idx)] = rssm[:col_name]

          end

        else
          next

        end  # if found
      end
    end

    return data_row
  end

  def find_index_of_cell_with_value(row, value=nil)
    row.cells.each do |cell|
      if value.present?
        return [true, cell.index] if cell.value.eql?(value)
        return [true, cell.index] if cell.value.downcase.eql?(value.downcase)

      else
        return [true, cell.index] if cell.value.match /^Arm Name 1$|^Comparison Name 1$/

      end
    end

    return [false, row.cells.length]
  end

  def style_data_columns_in_worksheet(col_grp_size, ws, style1, style2, style3, style4)
    style_array      = [style1, style2, style3, style4]
    found, start_idx = find_index_of_cell_with_value(ws.rows[0], 'Arm Name 1')
    found, start_idx = find_index_of_cell_with_value(ws.rows[0], 'Comparison Name 1') unless found
    end_idx          = ws.rows[0].length

    # Return if there are no styles to apply.
    return unless (col_grp_size.present? && found.present? && start_idx.present? && end_idx.present?)

    no_of_col_groups = (end_idx - start_idx)/col_grp_size
    no_of_col_groups.times do |n|
      n_add = n*col_grp_size

      case n%4
      when 0
        ws.col_style(((n_add + start_idx)..(n_add + start_idx + col_grp_size - 1)), style_array[0], options={})

      when 1
        ws.col_style(((n_add + start_idx)..(n_add + start_idx + col_grp_size - 1)), style_array[1], options={})

      when 2
        ws.col_style(((n_add + start_idx)..(n_add + start_idx + col_grp_size - 1)), style_array[2], options={})

      when 3
        ws.col_style(((n_add + start_idx)..(n_add + start_idx + col_grp_size - 1)), style_array[3], options={})

      end
    end
  end

  def set_ws_styles(ws)
    # From https://paletton.com/#uid=7001q0kiCFn8GVde7NVmtwSqXtg
    style1 = ws.styles.add_style(:bg_color => "FFBABA", :border => { :style => :thin, :color => '808080' })
    style2 = ws.styles.add_style(:bg_color => "FFF3BA", :border => { :style => :thin, :color => '808080' })
    style3 = ws.styles.add_style(:bg_color => "C5B7F1", :border => { :style => :thin, :color => '808080' })
    style4 = ws.styles.add_style(:bg_color => "B3F6B3", :border => { :style => :thin, :color => '808080' })

    return style1, style2, style3, style4
  end

  def md5_digest(extraction, rssm)
    signature_string = extraction[:extraction_info][:extraction_id].to_s\
      + extraction[:extraction_info][:consolidated].to_s\
      + extraction[:extraction_info][:username].to_s\
      + extraction[:extraction_info][:citation_id].to_s\
      + extraction[:extraction_info][:citation_name].to_s\
      + extraction[:extraction_info][:refman].to_s\
      + extraction[:extraction_info][:pmid].to_s\
      + extraction[:extraction_info][:authors].to_s\
      + extraction[:extraction_info][:publication_date].to_s\
      + rssm[:outcome_name].to_s\
      + rssm[:outcome_description].to_s\
      + rssm[:outcome_type].to_s\
      + rssm[:population_name].to_s

    Digest::MD5.hexdigest(signature_string)
  end

  def _export_diagnostic_test_ef_results
    _add_da_results_worksheets
    _print_da_results_headers
    _print_da_results_data

  end  # def _export_diagnostic_test_ef_results

  def _add_da_results_worksheets
    # 4 sheets: Descriptive Statistics, Special area for AUC and Q*, 2x2 Table and Test Accuracy Metrics.
    @ws_descriptive_statistics          = @package.workbook.add_worksheet(name: "Descriptive Statistics")
    @ws_special_area_for_auc_and_q_star = @package.workbook.add_worksheet(name: "Special area for AUC and Q-star")
    @ws_2x2_table                       = @package.workbook.add_worksheet(name: "2X2 Table")
    @ws_test_accuracy_metrics           = @package.workbook.add_worksheet(name: "Test Accuracy Metrics")
  end  # def _add_da_results_worksheets

  def _print_da_results_headers
    # Start printing rows to the sheets. First the basic headers:
    @ws_descriptive_statistics.add_row(
      @sheet_info.header_info +
      ['Diagnosis', 'Diagnosis Description', 'Population', 'Population Description', 'Digest', 'Timepoint', 'Timepoint Unit', "Comparison"] +
      _lsof_measures_in_rss(:descriptive_statistics)
    )
    @ws_special_area_for_auc_and_q_star.add_row(
      @sheet_info.header_info +
      ['Diagnosis', 'Diagnosis Description', 'Population', 'Population Description', 'Digest', 'Timepoint', 'Timepoint Unit', "Comparison"] +
      _lsof_measures_in_rss(:special_area_for_auc_and_q_star)
    )
    @ws_2x2_table.add_row(
      @sheet_info.header_info +
      ['Diagnosis', 'Diagnosis Description', 'Population', 'Population Description', 'Digest', 'Timepoint', 'Timepoint Unit', "Comparison"] +
      _lsof_measures_in_rss(:_2x2_table)
    )
    @ws_test_accuracy_metrics.add_row(
      @sheet_info.header_info +
      ['Diagnosis', 'Diagnosis Description', 'Population', 'Population Description', 'Digest', 'Timepoint', 'Timepoint Unit', "Comparison"] +
      _lsof_measures_in_rss(:test_accuracy_metrics)
    )
  end  # def _print_da_results_headers

  # Diagnostic Test Results are different from Standard Extraction.
  #   The measurements are always the same. There's currently no customization permitted.
  #   This may change in the future.
  #   This will return an array of measure names to use in the header.
  #
  #   returns Array
  def _lsof_measures_in_rss(rss_type)
    case rss_type
    when :descriptive_statistics
      rsstms = ResultStatisticSectionTypesMeasure
        .where(result_statistic_section_type_id: 5, default: true, type1_type_id: nil)
      @rsstms_descriptive_statistics = rsstms

    when :special_area_for_auc_and_q_star
      rsstms = ResultStatisticSectionTypesMeasure
        .where(result_statistic_section_type_id: 6, default: true, type1_type_id: nil)
      @rsstms_special_area_for_auc_and_q_star = rsstms

    when :_2x2_table
      rsstms = ResultStatisticSectionTypesMeasure
        .where(result_statistic_section_type_id: 7, default: true, type1_type_id: nil)
      @rsstms_2x2_table = rsstms

    when :test_accuracy_metrics
      rsstms = ResultStatisticSectionTypesMeasure
        .where(result_statistic_section_type_id: 8, default: true, type1_type_id: nil)
      @rsstms_test_accuracy_metrics = rsstms

    end  # case rss_type

    return rsstms.map { |rsstm| rsstm.measure.name }
  end  # def _lsof_measures_in_rss(rss_type)

  def _print_da_results_data
    @project.extractions.each do |extraction|
      #eefps = extraction
      #  .extractions_extraction_forms_projects_sections
      #  .joins(extraction_forms_projects_section: :section)
      #  .where(extraction_forms_projects_sections: { sections: { name: "Results" } })
      #  .first

      eefpst1_diagnoses = ExtractionsExtractionFormsProjectsSectionsType1
        .by_section_name_and_extraction_id_and_extraction_forms_project_id('Diagnoses',
                                                                           extraction.id,
                                                                           @project.extraction_forms_projects.first.id)

      #eefpst1_diagnostic_tests = ExtractionsExtractionFormsProjectsSectionsType1
      #  .by_section_name_and_extraction_id_and_extraction_forms_project_id('Diagnostic Tests',
      #                                                                     extraction.id,
      #                                                                     @project.extraction_forms_projects.first.id)

      eefpst1_diagnoses.each do |eefpst1_diagnosis|
        eefpst1_diagnosis.extractions_extraction_forms_projects_sections_type1_rows.each do |population|
          rss = population.result_statistic_sections.diagnostic_test_type_rsss.first
          rss.comparisons.each do |comparison|
            population.extractions_extraction_forms_projects_sections_type1_row_columns.each do |timepoint|
              _print_data_row(eefpst1_diagnosis, population, comparison, timepoint)
            end  # population.extractions_extraction_forms_projects_sections_type1_row_columns.each do |timepoint|
          end  # rss.comparisons.each do |comparison|
        end  # eefpst1_diagnosis.extractions_extraction_forms_projects_sections_type1_rows.each do |population|
      end  # eefpst1_diagnoses.each do |eefpst1_diagnosis|
    end  # @project.extractions.each do |extraction|
  end  # def _print_da_results_data

  def _print_data_row(eefpst1_diagnosis, population, comparison, timepoint)
    row_identifiers = _build_row_identifier
    diagnostic_test_type_rsss = population.result_statistic_sections.diagnostic_test_type_rsss

    # Descriptive Statistics.
    records = _fetch_records(diagnostic_test_type_rsss.first, timepoint, comparison)
    @ws_descriptive_statistics.add_row(row_identifiers + records.map(&:name))

    # Special Area for AUC and Q*
    records = _fetch_records(diagnostic_test_type_rsss.second, timepoint, comparison)
    @ws_special_area_for_auc_and_q_star.add_row(row_identifiers + records.map(&:name))

    # 2X2 Table
    records = _fetch_records(diagnostic_test_type_rsss.third, timepoint, comparison)
    @ws_2x2_table.add_row(row_identifiers + records.map(&:name))

    # Test Accuracy Metrics
    records = _fetch_records(diagnostic_test_type_rsss.fourth, timepoint, comparison)
    @ws_test_accuracy_metrics.add_row(row_identifiers + records.map(&:name))
  end  # def _print_data_row(eefpst1_diagnosis, population, comparison, timepoint)

  def _build_row_identifier
    #!!!
    return [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18]
  end  # def _build_row_identifier

  def _fetch_records(rss, timepoint, comparison)
    lsof_values = []
    rss.result_statistic_sections_measures.each do |rssm|
      lsof_values << TpsComparisonsRssm
        .find_record(timepoint=timepoint, comparison=comparison, result_statistic_sections_measure=rssm)
    end  # rss.result_statistic_sections_measures.each do |rssm|

    return lsof_values
  end  # def _fetch_records(rss)
end
