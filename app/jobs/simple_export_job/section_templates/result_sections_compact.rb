module SimpleExportJob::SectionTemplates::ResultSectionsCompact
  def build_result_sections_compact(kq_ids = [], print_empty_row = false)
    @project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        # If this is a results section then we proceed.
        next unless efps.extraction_forms_projects_section_type_id == 3

        # Create SheetInfo object for results sections.
        sheet_info = SimpleExportJob::SheetInfo.new(@project)

        # Build SheetInfo object by extraction.
        sheet_info.populate_sheet_info_with_extractions_results_data(sheet_info, kq_ids, efp, efps)

        ws_desc = @package.workbook.add_worksheet(name: 'Desc. Statistics')
        ws_bac  = @package.workbook.add_worksheet(name: 'BAC Comparisons')
        ws_wac  = @package.workbook.add_worksheet(name: 'WAC Comparisons')
        ws_net  = @package.workbook.add_worksheet(name: 'NET Differences')

        # Start printing rows to the sheets. First the basic headers:
        # ['Extraction ID', 'Username', 'Citation ID', 'Citation Name', 'RefMan', 'PMID']
        ws_desc_header = ws_desc.add_row(sheet_info.header_info + ['Outcome', 'Outcome Description', 'Outcome Type',
                                                                   'Population', 'Digest', 'Timepoint', 'Timepoint Unit', 'Arm', 'Arm Description', 'Measure', 'Value'])
        ws_bac_header  = ws_bac.add_row(sheet_info.header_info +  ['Outcome', 'Outcome Description', 'Outcome Type',
                                                                   'Population', 'Digest', 'Timepoint', 'Timepoint Unit', 'BAC Comparator',                    'Measure', 'Value'])
        ws_wac_header  = ws_wac.add_row(sheet_info.header_info +  ['Outcome', 'Outcome Description', 'Outcome Type',
                                                                   'Population', 'Digest', 'WAC Comparator',              'Arm', 'Arm Description', 'Measure', 'Value'])
        ws_net_header  = ws_net.add_row(sheet_info.header_info +  ['Outcome', 'Outcome Description', 'Outcome Type',
                                                                   'Population', 'Digest', 'WAC Comparator',              'BAC Comparator',                    'Measure', 'Value'])

        ws_desc_header.style = @highlight
        ws_bac_header.style  = @highlight
        ws_wac_header.style  = @highlight
        ws_net_header.style  = @highlight

        # We iterate each extraction and its rssms. Print a new line in the proper sheet 1 line per rssm.

        sheet_info.extractions.each do |_key, extraction|
          extraction[:rssms].each do |rssm|
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

            case rssm[:result_statistic_section_type_id]
            when 1
              new_row << rssm[:outcome_name]
              new_row << rssm[:outcome_description]
              new_row << rssm[:outcome_type]
              new_row << rssm[:population_name]
              new_row << md5_digest(extraction, rssm)
              new_row << rssm[:row_name]
              new_row << rssm[:row_unit]
              new_row << rssm[:col_name]
              new_row << rssm[:col_description]
              new_row << rssm[:measure_name]
              new_row << rssm[:rssm_values]

              ws_desc.add_row new_row if rssm[:rssm_values].present? || print_empty_row

            when 2
              new_row << rssm[:outcome_name]
              new_row << rssm[:outcome_description]
              new_row << rssm[:outcome_type]
              new_row << rssm[:population_name]
              new_row << md5_digest(extraction, rssm)
              new_row << rssm[:row_name]
              new_row << rssm[:row_unit]
              new_row << rssm[:col_name]
              new_row << rssm[:measure_name]
              new_row << rssm[:rssm_values]

              ws_bac.add_row new_row if rssm[:rssm_values].present? || print_empty_row

            when 3
              new_row << rssm[:outcome_name]
              new_row << rssm[:outcome_description]
              new_row << rssm[:outcome_type]
              new_row << rssm[:population_name]
              new_row << md5_digest(extraction, rssm)
              new_row << rssm[:row_name]
              new_row << rssm[:col_name]
              new_row << rssm[:col_description]
              new_row << rssm[:measure_name]
              new_row << rssm[:rssm_values]

              ws_wac.add_row new_row if rssm[:rssm_values].present? || print_empty_row

            when 4
              new_row << rssm[:outcome_name]
              new_row << rssm[:outcome_description]
              new_row << rssm[:outcome_type]
              new_row << rssm[:population_name]
              new_row << md5_digest(extraction, rssm)
              new_row << rssm[:row_name]
              new_row << rssm[:col_name]
              new_row << rssm[:measure_name]
              new_row << rssm[:rssm_values]

              ws_net.add_row new_row if rssm[:rssm_values].present? || print_empty_row

            end # case rssm[:result_statistic_section_type_id]
          end # END extraction[:rssms].each do |rssm|
        end # END sheet_info.extractions.each do |key, extraction|
      end # END efp.extraction_forms_projects_sections.each do |efps|
    end  # END @project.extraction_forms_projects.each do |efp|
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
end
