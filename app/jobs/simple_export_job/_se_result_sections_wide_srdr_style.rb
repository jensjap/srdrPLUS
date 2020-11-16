require 'simple_export_job/sheet_info'

def build_result_sections_wide_srdr_style(p, project, highlight, wrap, kq_ids=[], print_empty_row=false)
  project.extraction_forms_projects.each do |efp|
    efp.extraction_forms_projects_sections.each do |efps|

      # If this is a results section then we proceed.
      if efps.extraction_forms_projects_section_type_id == 3

        # Create SheetInfo object for results sections.
        sheet_info = SheetInfo.new

        # Build SheetInfo object by extraction.
        populate_sheet_info_with_extractions_results_data(sheet_info, project, kq_ids, efp, efps)

        ws_desc = p.workbook.add_worksheet(name: "Desc. Statistics")
        ws_bac  = p.workbook.add_worksheet(name: "BAC Comparisons")
        ws_wac  = p.workbook.add_worksheet(name: "WAC Comparisons")
        ws_net  = p.workbook.add_worksheet(name: "NET Differences")

        # Start printing rows to the sheets. First the basic headers:
        #['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
        ws_desc_header = ws_desc.add_row(sheet_info.header_info + ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'])
        ws_bac_header  = ws_bac.add_row(sheet_info.header_info +  ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'Timepoint', 'Timepoint Unit'])
        ws_wac_header  = ws_wac.add_row(sheet_info.header_info +  ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'WAC Comparator'])
        ws_net_header  = ws_net.add_row(sheet_info.header_info +  ['Outcome', 'Outcome Description', 'Outcome Type', 'Population', 'Digest', 'WAC Comparator'])

        ws_desc_header.style = highlight
        ws_bac_header.style  = highlight
        ws_wac_header.style  = highlight
        ws_net_header.style  = highlight

        sheet_info.extractions.each do |e_key, extraction|
          # Column refers to the columns in the results quadrants.
          #
          #   Desc statistics: (Timepoints x Arms): column => Arms
          #   BAC comparisons: (Timepoints x BAC) : column => BAC
          #   WAC comparisons: (   WAC     x Arms): column => Arms
          #   NET comparisons: (   WAC     x BAC) : column => BAC
          extraction[:rss_columns].each do |rss_type_id, rss_type|
            rss_type.each do |rss_row_id, outcomes|
              outcomes.each do |outcome_id, populations|
                populations.each do |population_id, rss_rows|
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
                  rssm = rss_rows.values[0][0]
                  case rss_type_id
                  when 1
                    new_row << rssm[:outcome_name]
                    new_row << rssm[:outcome_description]
                    new_row << rssm[:outcome_type]
                    new_row << rssm[:population_name]
                    new_row << md5_digest(extraction, rssm)
                    new_row << rssm[:row_name]
                    new_row << rssm[:row_unit]

                    rss_rows.each do |col_id, values|
                      _first = true
                      values.each do |_rssm|
                        if _first
                          new_row << _rssm[:col_name]
                          new_row << _rssm[:col_description]
                        end
                        new_row << _rssm[:measure_name]
                        new_row << _rssm[:rssm_values]
                        _first = false
                      end  # rss_rows.each do |rssm|
                    end  # rss_rows.each do |col_id, values|

                    ws_desc.add_row new_row

                  when 2
                    new_row << rssm[:outcome_name]
                    new_row << rssm[:outcome_description]
                    new_row << rssm[:outcome_type]
                    new_row << rssm[:population_name]
                    new_row << md5_digest(extraction, rssm)
                    new_row << rssm[:row_name]
                    new_row << rssm[:row_unit]

                    rss_rows.each do |col_id, values|
                      _first = true
                      values.each do |_rssm|
                        if _first
                          new_row << _rssm[:col_name]
                        end
                        new_row << _rssm[:measure_name]
                        new_row << _rssm[:rssm_values]
                        _first = false
                      end  # rss_rows.each do |rssm|
                    end  # rss_rows.each do |col_id, values|

                    ws_bac.add_row new_row

                  when 3
                    new_row << rssm[:outcome_name]
                    new_row << rssm[:outcome_description]
                    new_row << rssm[:outcome_type]
                    new_row << rssm[:population_name]
                    new_row << md5_digest(extraction, rssm)
                    new_row << rssm[:row_name]

                    rss_rows.each do |col_id, values|
                      _first = true
                      values.each do |_rssm|
                        if _first
                          new_row << _rssm[:col_name]
                          new_row << _rssm[:col_description]
                        end
                        new_row << _rssm[:measure_name]
                        new_row << _rssm[:rssm_values]
                        _first = false
                      end  # rss_rows.each do |rssm|
                    end  # rss_rows.each do |col_id, values|

                    ws_wac.add_row new_row

                  when 4
                    new_row << rssm[:outcome_name]
                    new_row << rssm[:outcome_description]
                    new_row << rssm[:outcome_type]
                    new_row << rssm[:population_name]
                    new_row << md5_digest(extraction, rssm)
                    new_row << rssm[:row_name]

                    rss_rows.each do |col_id, values|
                      _first = true
                      values.each do |_rssm|
                        if _first
                          new_row << _rssm[:col_name]
                        end
                        new_row << _rssm[:measure_name]
                        new_row << _rssm[:rssm_values]
                        _first = false
                      end  # rss_rows.each do |rssm|
                    end  # rss_rows.each do |col_id, values|

                    ws_net.add_row new_row

                  end  # case rss_type_id
                end  # populations.each do |population_id, rss_rows|
              end  # outcomes.each do |outcome_id, populations|
            end  # rss_type.each do ||
          end  # extraction[:rss_columns].each do |rss_type_id, rss_type|




            # rss_row.each do |row_id, rssms|
            #   new_row = []
            #   new_row << extraction[:extraction_info][:extraction_id]
            #   new_row << extraction[:extraction_info][:consolidated]
            #   new_row << extraction[:extraction_info][:username]
            #   new_row << extraction[:extraction_info][:citation_id]
            #   new_row << extraction[:extraction_info][:citation_name]
            #   new_row << extraction[:extraction_info][:refman]
            #   new_row << extraction[:extraction_info][:pmid]
            #   new_row << extraction[:extraction_info][:authors]
            #   new_row << extraction[:extraction_info][:publication_date]
            #   new_row << extraction[:extraction_info][:kq_selection]

            #   case rss_type_id
            #   when 1
            #     new_row << rssm[:outcome_name]
            #     new_row << rssm[:outcome_description]
            #     new_row << rssm[:outcome_type]
            #     new_row << rssm[:population_name]
            #     new_row << md5_digest(extraction, rssm)
            #     new_row << rssm[:row_name]
            #     new_row << rssm[:row_unit]

            #     rss_row.each do |_rssm|
            #       new_row << _rssm[:col_name]
            #       new_row << _rssm[:col_description]
            #       new_row << _rssm[:measure_name]
            #       new_row << _rssm[:rssm_values]
            #     end  # rss_row.each do |rssm|

            #     ws_desc.add_row new_row

            #   when 2
            #     new_row << rssm[:outcome_name]
            #     new_row << rssm[:outcome_description]
            #     new_row << rssm[:outcome_type]
            #     new_row << rssm[:population_name]
            #     new_row << md5_digest(extraction, rssm)
            #     new_row << rssm[:row_name]
            #     new_row << rssm[:row_unit]

            #     rss_row.each do |_rssm|
            #       new_row << _rssm[:col_name]
            #       new_row << _rssm[:measure_name]
            #       new_row << _rssm[:rssm_values]
            #     end  # rss_row.each do |rssm|

            #     ws_bac.add_row new_row

            #   when 3
            #     new_row << rssm[:outcome_name]
            #     new_row << rssm[:outcome_description]
            #     new_row << rssm[:outcome_type]
            #     new_row << rssm[:population_name]
            #     new_row << md5_digest(extraction, rssm)
            #     new_row << rssm[:row_name]

            #     rss_row.each do |_rssm|
            #       new_row << _rssm[:col_name]
            #       new_row << _rssm[:col_description]
            #       new_row << _rssm[:measure_name]
            #       new_row << _rssm[:rssm_values]
            #     end  # rss_row.each do |rssm|

            #     ws_wac.add_row new_row

            #   when 4
            #     new_row << rssm[:outcome_name]
            #     new_row << rssm[:outcome_description]
            #     new_row << rssm[:outcome_type]
            #     new_row << rssm[:population_name]
            #     new_row << md5_digest(extraction, rssm)
            #     new_row << rssm[:row_name]

            #     rss_row.each do |_rssm|
            #       new_row << _rssm[:col_name]
            #       new_row << _rssm[:measure_name]
            #       new_row << _rssm[:rssm_values]
            #     end  # rss_row.each do |rssm|

            #     ws_net.add_row new_row

            #   end
            # end  # rss_row.each do |row_id, rssms|




        end  # sheet_info.extractions.each do |e_key, extraction|
      end  # END if efps.extraction_forms_projects_section_type_id == 3
    end  # END efp.extraction_forms_projects_sections.each do |efps|
  end  # END project.extraction_forms_projects.each do |efp|
end
