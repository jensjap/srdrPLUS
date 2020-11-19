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
                      new_row.concat(build_data_row(rss_cols, desc_cont_header))
                      ws_descriptive_statistics_continuous_outcomes.add_row(new_row)

                    elsif rssm[:outcome_type].eql? "Categorical"
                      new_row.concat(build_data_row(rss_cols, desc_cat_header))
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
                      new_row.concat(build_data_row(rss_cols, bac_cont_header))
                      ws_bac_statistics_continuous_outcomes.add_row(new_row)

                    elsif rssm[:outcome_type].eql? "Categorical"
                      new_row.concat(build_data_row(rss_cols, bac_cat_header))
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
        end  # sheet_info.extractions.each do |e_key, extraction|






        # sheet_info.extractions.each do |e_key, extraction|
        #   # Column refers to the columns in the results quadrants.
        #   #
        #   #   Desc statistics: (Timepoints x Arms): column => Arms
        #   #   BAC comparisons: (Timepoints x BAC) : column => BAC
        #   #   WAC comparisons: (   WAC     x Arms): column => Arms
        #   #   NET comparisons: (   WAC     x BAC) : column => BAC
        #   extraction[:rss_columns].each do |rss_type_id, outcomes|
        #     outcomes.each do |outcome_id, populations|
        #       populations.each do |population_id, rss_rows|
        #         rss_rows.each do |row_id, rss_cols|
        #           new_row = []
        #           new_row << extraction[:extraction_info][:extraction_id]
        #           new_row << extraction[:extraction_info][:consolidated]
        #           new_row << extraction[:extraction_info][:username]
        #           new_row << extraction[:extraction_info][:citation_id]
        #           new_row << extraction[:extraction_info][:citation_name]
        #           new_row << extraction[:extraction_info][:refman]
        #           new_row << extraction[:extraction_info][:pmid]
        #           new_row << extraction[:extraction_info][:authors]
        #           new_row << extraction[:extraction_info][:publication_date]
        #           new_row << extraction[:extraction_info][:kq_selection]

        #           # Pick a representative rssm just for information.
        #           rssm = rss_cols.values[0][0]
        #           case rss_type_id
        #           when 1
        #             new_row << rssm[:outcome_name]
        #             new_row << rssm[:outcome_description]
        #             new_row << rssm[:outcome_type]
        #             new_row << rssm[:population_name]
        #             new_row << md5_digest(extraction, rssm)
        #             new_row << rssm[:row_name]
        #             new_row << rssm[:row_unit]

        #             rss_cols.each do |col_id, values|
        #               _first = true
        #               values.each do |_rssm|
        #                 if _first
        #                   new_row << _rssm[:col_name]
        #                   new_row << _rssm[:col_description]
        #                 end
        #                 new_row << _rssm[:measure_name]
        #                 new_row << _rssm[:rssm_values]
        #                 _first = false
        #               end  # rss_cols.each do |rssm|
        #             end  # rss_cols.each do |col_id, values|

        #             ws_desc.add_row new_row

        #           when 2
        #             new_row << rssm[:outcome_name]
        #             new_row << rssm[:outcome_description]
        #             new_row << rssm[:outcome_type]
        #             new_row << rssm[:population_name]
        #             new_row << md5_digest(extraction, rssm)
        #             new_row << rssm[:row_name]
        #             new_row << rssm[:row_unit]

        #             rss_cols.each do |col_id, values|
        #               _first = true
        #               values.each do |_rssm|
        #                 if _first
        #                   new_row << _rssm[:col_name]
        #                 end
        #                 new_row << _rssm[:measure_name]
        #                 new_row << _rssm[:rssm_values]
        #                 _first = false
        #               end  # rss_cols.each do |rssm|
        #             end  # rss_cols.each do |col_id, values|

        #             ws_bac.add_row new_row

        #           when 3
        #             new_row << rssm[:outcome_name]
        #             new_row << rssm[:outcome_description]
        #             new_row << rssm[:outcome_type]
        #             new_row << rssm[:population_name]
        #             new_row << md5_digest(extraction, rssm)
        #             new_row << rssm[:row_name]

        #             rss_cols.each do |col_id, values|
        #               _first = true
        #               values.each do |_rssm|
        #                 if _first
        #                   new_row << _rssm[:col_name]
        #                   new_row << _rssm[:col_description]
        #                 end
        #                 new_row << _rssm[:measure_name]
        #                 new_row << _rssm[:rssm_values]
        #                 _first = false
        #               end  # rss_cols.each do |rssm|
        #             end  # rss_cols.each do |col_id, values|

        #             ws_wac.add_row new_row

        #           when 4
        #             new_row << rssm[:outcome_name]
        #             new_row << rssm[:outcome_description]
        #             new_row << rssm[:outcome_type]
        #             new_row << rssm[:population_name]
        #             new_row << md5_digest(extraction, rssm)
        #             new_row << rssm[:row_name]

        #             rss_cols.each do |col_id, values|
        #               _first = true
        #               values.each do |_rssm|
        #                 if _first
        #                   new_row << _rssm[:col_name]
        #                 end
        #                 new_row << _rssm[:measure_name]
        #                 new_row << _rssm[:rssm_values]
        #                 _first = false
        #               end  # rss_cols.each do |rssm|
        #             end  # rss_cols.each do |col_id, values|

        #             ws_net.add_row new_row

        #           end  # case rss_type_id
        #         end  # rss_rows.each do |row_id, rss_cols|
        #       end  # populations.each do |population_id, rss_rows|
        #     end  # outcomes.each do ||
        #   end  # extraction[:rss_columns].each do |rss_type_id, outcomes|
        # end  # sheet_info.extractions.each do |e_key, extraction|

        desc_cont_header.style = highlight
        desc_cat_header.style  = highlight
        bac_cont_header.style  = highlight
        bac_cat_header.style   = highlight
        wac_header.style  = highlight
        net_header.style  = highlight

      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end

def build_data_row(rss_cols, header)
  # data_row is just the portion of the row that is below the headers:
  # ['Arm Name 1', 'Arm Description 1', 'Measure 1', 'Measure 2', 'Arm Name 2', 'Arm Description 2', 'Measure 1', ...]
  data_row = []

  # We generalize the naming of Arm or Comparison by calling it rss column or just col.
  # cnt_col is the number of rss columns
  cnt_col = rss_cols.length
  found, idx_start_of_data = find_index_of_cell_with_value(header)
  length_of_data_header = header.length - (idx_start_of_data)
  length_of_each_col_group = length_of_data_header/cnt_col
  length_of_identifiers = header.length - length_of_data_header

  rss_cols.each_with_index do |col, idx|
    col_id = col[0]
    col[1].each do |rssm|
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
      end
    end
  end

  return data_row
end

def find_index_of_cell_with_value(row, value=nil)
  row.cells.each do |cell|
    if value.present?
      return [true, cell.index] if cell.value.eql? value

    else
      return [true, cell.index] if cell.value.match /^Arm Name 1$|^Comparison Name 1$/

    end
  end

  return [false, row.cells.length]
end
