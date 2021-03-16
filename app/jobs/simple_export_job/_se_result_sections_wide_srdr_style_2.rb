require 'simple_export_job/sheet_info'

def build_result_sections_wide_srdr_style_2(p, project, highlight, wrap, kq_ids=[], print_empty_row=false)
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a results section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 3

        # Create SheetInfo object for results sections.
        sheet_info = SheetInfo.new

        # Build SheetInfo object by extraction.
        populate_sheet_info_with_extractions_results_data(sheet_info, project, kq_ids, efp, efps)

        # Create and name worksheets.
        ws_descriptive_statistics_continuous_outcomes   = p.workbook.add_worksheet(name: "Continuous - Desc. Statistics")
        ws_descriptive_statistics_categorical_outcomes  = p.workbook.add_worksheet(name: "Categorical - Desc. Statistics")
        ws_bac_statistics_continuous_outcomes  = p.workbook.add_worksheet(name: "Continuous - BAC Comparisons")
        ws_bac_statistics_categorical_outcomes = p.workbook.add_worksheet(name: "Categorical - BAC Comparisons")
        ws_wac_statistics = p.workbook.add_worksheet(name: "WAC Comparisons")
        ws_net_statistics = p.workbook.add_worksheet(name: "NET Differences")

        # Start printing rows to the sheets. First the basic headers:
        #   Categorical populations only apply to Desc. Statistics and BAC Comparisons.
        #   WAC and Net Differences only apply to Continuous.
        desc_cont_header = ws_descriptive_statistics_continuous_outcomes.add_row(
          sheet_info.header_info +
          ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
          sheet_info.data_headers(1, "Continuous", "Arm")
        )
        desc_cat_header = ws_descriptive_statistics_categorical_outcomes.add_row(
          sheet_info.header_info +
          ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
          sheet_info.data_headers(1, "Categorical", "Arm")
        )
        bac_cont_header = ws_bac_statistics_continuous_outcomes.add_row(
          sheet_info.header_info +
          ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
          sheet_info.data_headers(2, "Continuous", "Comparison")
        )
        bac_cat_header = ws_bac_statistics_categorical_outcomes.add_row(
          sheet_info.header_info +
          ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'] +
          sheet_info.data_headers(2, "Categorical", "Comparison")
        )
        wac_header = ws_wac_statistics.add_row(
          sheet_info.header_info +
          ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'WAC Comparator'] +
          sheet_info.data_headers(3, "Continuous", "Arm")
        )
        net_header = ws_net_statistics.add_row(
          sheet_info.header_info +
          ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'WAC Comparator'] +
          sheet_info.data_headers(4, "Continuous", "Comparison")
        )

        sheet_info.extractions.each do |e_key, extraction|
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
                      new_row.concat(build_data_row(rss_cols, desc_cont_header, sheet_info))
                      ws_descriptive_statistics_continuous_outcomes.add_row(new_row)

                    elsif rssm[:outcome_type].eql? "Categorical"
                      new_row.concat(build_data_row(rss_cols, desc_cat_header, sheet_info))
                      ws_descriptive_statistics_categorical_outcomes.add_row(new_row)

                    else
                      raise 'Unknown outcome_type'

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
                      new_row.concat(build_data_row(rss_cols, bac_cont_header, sheet_info))
                      ws_bac_statistics_continuous_outcomes.add_row(new_row)

                    elsif rssm[:outcome_type].eql? "Categorical"
                      new_row.concat(build_data_row(rss_cols, bac_cat_header, sheet_info))
                      ws_bac_statistics_categorical_outcomes.add_row(new_row)

                    else
                      raise 'Unknown outcome_type'

                    end

                  when 3
                    new_row << rssm[:outcome_name]
                    new_row << rssm[:outcome_description]
                    new_row << rssm[:outcome_type]
                    new_row << rssm[:population_name]
                    new_row << md5_digest(extraction, rssm)
                    new_row << rssm[:row_name]

                    if rssm[:outcome_type].eql? "Continuous"
                      new_row.concat(build_data_row(rss_cols, wac_header, sheet_info))
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
                      new_row.concat(build_data_row(rss_cols, net_header, sheet_info))
                      ws_net_statistics.add_row(new_row)

                    else
                      # According to Ian, WAC does not make sense for Categorical

                    end

                  end  # case rss_type_id
                end  # rss_rows.each do |row_id, rss_cols|
              end  # populations.each do |population_id, rss_rows|
            end  # outcomes.each do |outcome_id, populations|
          end  # extraction[:rss_columns].each do |rss_type_id, outcomes|
        end  # sheet_info.extractions.each do |e_key, extraction|

        # Style header row.
        desc_cont_header.style = highlight
        desc_cat_header.style  = highlight
        bac_cont_header.style  = highlight
        bac_cat_header.style   = highlight
        wac_header.style  = highlight
        net_header.style  = highlight

        # Set styles for each worksheet.
        style_dscoo1, style_dscoo2, style_dscoo3, style_dscoo4 = set_ws_styles(ws_descriptive_statistics_continuous_outcomes)
        style_dscao1, style_dscao2, style_dscao3, style_dscao4 = set_ws_styles(ws_descriptive_statistics_categorical_outcomes)
        style_bscoo1, style_bscoo2, style_bscoo3, style_bscoo4 = set_ws_styles(ws_bac_statistics_continuous_outcomes)
        style_bscao1, style_bscao2, style_bscao3, style_bscao4 = set_ws_styles(ws_bac_statistics_categorical_outcomes)
        style_wacst1, style_wacst2, style_wacst3, style_wacst4 = set_ws_styles(ws_wac_statistics)
        style_netst1, style_netst2, style_netst3, style_netst4 = set_ws_styles(ws_net_statistics)

        style_data_columns_in_worksheet(
          sheet_info.data_header_hash.try(:[], :max_col).try(:[], 1).try(:[], "Continuous").try(:[], :no_of_measures),
          ws_descriptive_statistics_continuous_outcomes,
          style_dscoo1, style_dscoo2, style_dscoo3, style_dscoo4)
        style_data_columns_in_worksheet(
          sheet_info.data_header_hash.try(:[], :max_col).try(:[], 1).try(:[], "Categorical").try(:[], :no_of_measures),
          ws_descriptive_statistics_categorical_outcomes,
          style_dscao1, style_dscao2, style_dscao3, style_dscao4)
        style_data_columns_in_worksheet(
          sheet_info.data_header_hash.try(:[], :max_col).try(:[], 2).try(:[], "Continuous").try(:[], :no_of_measures),
          ws_bac_statistics_continuous_outcomes,
          style_bscoo1, style_bscoo2, style_bscoo3, style_bscoo4)
        style_data_columns_in_worksheet(
          sheet_info.data_header_hash.try(:[], :max_col).try(:[], 2).try(:[], "Categorical").try(:[], :no_of_measures),
          ws_bac_statistics_categorical_outcomes,
          style_bscao1, style_bscao2, style_bscao3, style_bscao4)
        style_data_columns_in_worksheet(
          sheet_info.data_header_hash.try(:[], :max_col).try(:[], 3).try(:[], "Continuous").try(:[], :no_of_measures),
          ws_wac_statistics,
          style_wacst1, style_wacst2, style_wacst3, style_wacst4)
        style_data_columns_in_worksheet(
          sheet_info.data_header_hash.try(:[], :max_col).try(:[], 4).try(:[], "Continuous").try(:[], :no_of_measures),
          ws_net_statistics,
          style_netst1, style_netst2, style_netst3, style_netst4)

      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end

def build_data_row(rss_cols, header, sheet_info)
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
      length_of_each_col_group = sheet_info.data_header_hash.try(:[], :max_col).try(:[], rssm[:result_statistic_section_type_id]).try(:[], rssm[:outcome_type]).try(:[], :no_of_measures)

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
