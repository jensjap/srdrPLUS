module ConsolidationHelper
  extend ActiveSupport::Concern 
  included do
    # The point is to go through all the extractions and find what they have in common.
    # Anything they have in common can be copied to the consolidated extraction (self).
    def auto_consolidate(extractions)
      # make sure the citations_projects are all the same
      # if (extractions.pluck(:citations_project_id) + [self.citations_project_id]).uniq.length > 1
        #return false
      # end

      # what i want to do is to build different hashes to store the structure/differences
      # for arms
      t1_hash = {}
      # for populations
      p_hash = {}
      # for timepoints
      tp_hash = {}
      # for question records (different than result records)
      r_hash = {}
      # for rssms
      rssm_hash = {}
      # for comparisons, this one stores array of comparison ids instead of extraction ids
      c_hash = {}
      # for rssm 3-way join tables
      three_hash = {}
      # store cloned comparisons
      cloned_c_hash = {}
      # store result records
      result_r_hash = {}

      extractions.each do |extraction|
        #we need to do type1 sections first
        t1_eefps = extraction.extractions_extraction_forms_projects_sections.
          joins(:extraction_forms_projects_section).
          includes(extractions_extraction_forms_projects_sections_type1s: [{extractions_extraction_forms_projects_sections_type1_rows: [{result_statistic_sections: [:comparisons, {result_statistic_sections_measures: [:tps_comparisons_rssms, :comparisons_arms_rssms, {tps_arms_rssms: [:timepoint, {extractions_extraction_forms_projects_sections_type1: :extractions_extraction_forms_projects_section}]}, :wacs_bacs_rssms]}]}, :extractions_extraction_forms_projects_sections_type1_row_columns]}, :type1]).
          where(extraction_forms_projects_sections:
                {extraction_forms_projects_section_type_id: 1})

        #Type 1 sections
        t1_eefps.each do |eefps|
          efps_id = eefps.extraction_forms_projects_section_id.to_s
          eefps_t1s = eefps.extractions_extraction_forms_projects_sections_type1s
          eefps_t1s.each do |eefps_t1|
            type1 = eefps_t1.type1
            type1_id = type1.id.to_s

            t1_hash[efps_id] ||= {}
            t1_hash[efps_id][type1_id] ||= []
            t1_hash[efps_id][type1_id] << extraction.id

            # this is stylistically weird but it prevents the loop below to crash
            p_hash[efps_id] ||= {}
            p_hash[efps_id][type1_id] ||= {}

            tp_hash[efps_id] ||= {}
            tp_hash[efps_id][type1_id] ||= {}

            rssm_hash[efps_id] ||= {}
            rssm_hash[efps_id][type1_id] ||= {}

            c_hash[efps_id] ||= {}
            c_hash[efps_id][type1_id] ||= {}

            three_hash[efps_id] ||= {}
            three_hash[efps_id][type1_id] ||= {}

            result_r_hash[efps_id] ||= {}
            result_r_hash[efps_id][type1_id] ||= {}


            # If there are timepoints and populations, we need to consolidate those as well using a similar hash method
            eefps_t1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefps_t1_row|
              population_name_id = eefps_t1_row.population_name_id.to_s

              p_hash[efps_id][type1_id][population_name_id] ||= []
              p_hash[efps_id][type1_id][population_name_id] << extraction.id

              tp_hash[efps_id][type1_id][population_name_id] ||= {}

              rssm_hash[efps_id][type1_id][population_name_id] ||= {}

              c_hash[efps_id][type1_id][population_name_id] ||= {}

              three_hash[efps_id][type1_id][population_name_id] ||= {}

              result_r_hash[efps_id][type1_id][population_name_id] ||= {}

              eefps_t1_row.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefps_t1_row_column|
                tp_name_id = eefps_t1_row_column.timepoint_name_id.to_s
                is_baseline = eefps_t1_row_column.is_baseline
                tp_hash[efps_id][type1_id][population_name_id][tp_name_id] ||= {}
                tp_hash[efps_id][type1_id][population_name_id][tp_name_id][is_baseline] ||= []
                tp_hash[efps_id][type1_id][population_name_id][tp_name_id][is_baseline] << extraction.id
              end

              eefps_t1_row.result_statistic_sections.each do |rss|
                rss_type_id = rss.result_statistic_section_type_id.to_s

                rssm_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}
                c_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}
                three_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}
                result_r_hash[efps_id][type1_id][population_name_id][rss_type_id] ||= {}

                rss.comparisons.each do |comparison|
                  # thank the maker for pretty_print_export_header --Birol
                  comparison_name = comparison.tokenize

                  c_hash[efps_id][type1_id][population_name_id][rss_type_id][comparison_name] ||= []
                  c_hash[efps_id][type1_id][population_name_id][rss_type_id][comparison_name] << comparison.id

                end

                rss.result_statistic_sections_measures.each do |rssm|
                  measure_id = rssm.measure_id.to_s

                  rssm_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] ||= []
                  rssm_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] << extraction.id

                  three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] ||= {}
                  result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id] ||= {}

                  case rss_type_id
                  # Descriptive Statistics
                  when "1"
                    rssm.tps_arms_rssms.each do |tps_arms_rssm|

                      # !!! What do we do with this?
                      next if tps_arms_rssm.timepoint.blank?

                      tp_name_id = tps_arms_rssm.timepoint.timepoint_name_id.to_s
                      arm_efps_id = tps_arms_rssm.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section_id
                      arm_name_id = tps_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1_id
                      record_name = tps_arms_rssm.records.first.name
                      is_baseline = tps_arms_rssm.timepoint.is_baseline

                      # this is for matching the three way join record, tps_arms_rssms
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id][arm_name_id] ||= []
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id][arm_name_id] << extraction.id

                      # this is for matching the record entry
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id][arm_name_id] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id][arm_name_id][record_name] ||= []
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][arm_efps_id][arm_name_id][record_name] << extraction.id
                    end

                  when "2"
                    # Between Arms Comparisons
                    rssm.tps_comparisons_rssms.each do |tps_comparisons_rssm|

                      next if tps_comparisons_rssm.timepoint.blank?

                      tp_name_id = tps_comparisons_rssm.timepoint.timepoint_name_id
                      is_baseline = tps_comparisons_rssm.timepoint.is_baseline
                      comparison_name = tps_comparisons_rssm.comparison.tokenize
                      record_name = tps_comparisons_rssm.records.first.name

                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][comparison_name] ||= []
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][comparison_name] << extraction.id

                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][comparison_name] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][comparison_name][record_name] ||= []
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][comparison_name][record_name] << extraction.id
                    end

                  when "3"
                    # Within Arm Comparisons
                    rssm.comparisons_arms_rssms.each do |comparisons_arms_rssm|

                      #next if comparisons_arms_rssm.timepoint.blank?

                      comparison_name = comparisons_arms_rssm.comparison.tokenize
                      arm_efps_id = comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1.extractions_extraction_forms_projects_section.extraction_forms_projects_section.id
                      arm_name_id = comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1_id
                      record_name = comparisons_arms_rssm.records.first.name

                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id] ||= []
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id] << extraction.id

                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id][record_name] ||= []
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][arm_efps_id][arm_name_id][record_name] << extraction.id
                    end

                  when "4"
                    rssm.wacs_bacs_rssms.each do |wacs_bacs_rssm|

                      #next if wacs_bacs_rssm.timepoint.blank?

                      wac_name = wacs_bacs_rssm.wac.tokenize
                      bac_name = wacs_bacs_rssm.bac.tokenize
                      record_name = wacs_bacs_rssm.records.first.name

                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name] ||= {}
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name] ||= []
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name] << extraction.id

                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name] ||= {}
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name][record_name] ||= []
                      result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name][record_name] << extraction.id
                    end

                  else
                    # why would there ever be a different rss type except when in testing environment
                  end
                end
              end
            end
          end
        end

        # now type2 sections
        eefps_t2 = extraction.extractions_extraction_forms_projects_sections.
          joins(:extraction_forms_projects_section).
          where(extraction_forms_projects_sections:
                {extraction_forms_projects_section_type_id: 2})

        #iterate over type2 eefpss
        eefps_t2.each do |eefps|
          if (eefps.link_to_type1.present? and not eefps.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1) or
             (not eefps.link_to_type1.present? and eefps.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1)
            next
          end
          extraction = eefps.extraction
          efps = eefps.extraction_forms_projects_section
          efps_id = efps.id.to_s
          # for records
          r_hash[efps_id] ||= {}

          eefps.extractions_extraction_forms_projects_sections_question_row_column_fields.each do |eefps_qrcf|
            # we dont want to bother with this stuff if there is no data
            if eefps_qrcf.records.first.nil?
              #byebug
              next
            end

            qrcf_id = eefps_qrcf.question_row_column_field.id.to_s

            linked_efps_id = (eefps.extraction_forms_projects_section.link_to_type1 and eefps.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1) ? eefps.extraction_forms_projects_section.link_to_type1.id.to_s : nil


            t1_id = eefps_qrcf.extractions_extraction_forms_projects_sections_type1.present? ?
                         eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1.id.to_s : nil

            t1_type_id = ( eefps_qrcf.extractions_extraction_forms_projects_sections_type1.present? and
                           eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1_type.present? ) ?
                           eefps_qrcf.extractions_extraction_forms_projects_sections_type1.type1_type_id.to_s : nil

            record_name = eefps_qrcf.records.first.name

            r_hash[efps_id][linked_efps_id] ||= {}
            r_hash[efps_id][linked_efps_id][t1_id] ||= {}
            r_hash[efps_id][linked_efps_id][t1_id][t1_type_id] ||= {}
            r_hash[efps_id][linked_efps_id][t1_id][t1_type_id][qrcf_id] ||= {}
            r_hash[efps_id][linked_efps_id][t1_id][t1_type_id][qrcf_id][record_name] ||= []
            r_hash[efps_id][linked_efps_id][t1_id][t1_type_id][qrcf_id][record_name] << extraction.id
          end
        end
      end


      #create the same type1 in self
      t1_hash.each do |efps_id, t1_efps_hash|
        t1_efps_hash.each do |type1_id, t1_es|
          if t1_es.length == extractions.length
            eefps = self.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section_id: efps_id)
            type1 = Type1.find(type1_id)

            eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by(
              extractions_extraction_forms_projects_section: eefps,
              type1: type1 )

            # population and timepoint creation
            p_hash[efps_id][type1_id].each do |population_name_id, p_es|
              if p_es.length == extractions.length
                population_name = PopulationName.find(population_name_id)
                eefps_t1_row = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by(
                  extractions_extraction_forms_projects_sections_type1: eefps_t1,
                  population_name: population_name )

                tp_hash[efps_id][type1_id][population_name_id].each do |tp_name_id, tp_bl_hash|
                  tp_bl_hash.each do |is_baseline, t_es|
                    if t_es.length == extractions.length
                      timepoint_name = TimepointName.find(tp_name_id)
                      ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by(
                        extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row,
                        is_baseline: is_baseline, #should this be true in some cases?
                        timepoint_name: timepoint_name )
                    end
                  end
                end

                eefps_t1_row.result_statistic_sections.each do |rss|
                  rss_type_id = rss.result_statistic_section_type.id.to_s

                  # clone comparisons for the consolidated extraction
                  next if c_hash[efps_id][type1_id][population_name_id][rss_type_id].nil?
                  c_hash[efps_id][type1_id][population_name_id][rss_type_id].each do |comparison_name, comparison_arr|
                    if comparison_arr.length == extractions.length
                      rss.comparisons.each do |existing_comp|
                        if existing_comp.tokenize == comparison_name
                          cloned_c_hash[comparison_name] = existing_comp
                          break
                        end
                      end

                      if cloned_c_hash[comparison_name].nil?
                        # get one comparison to clone
                        # is it possible that this comparable exists? what then?
                        master_comp = Comparison.find(comparison_arr.first)
                        #clone_comp = Comparison.create!(result_statistic_section: rss)
                        clone_comp = Comparison.create
                        clone_comp.result_statistic_sections << rss
                        master_comp.comparate_groups.each do |old_comparate_group|
                          new_comparate_group = ComparateGroup.create(comparison: clone_comp)
                          old_comparate_group.comparates.each do |old_comparate|
                            old_comparable_element = old_comparate.comparable_element
                            old_comparable = old_comparable_element.comparable
                            if old_comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1
                              comp_t1 = old_comparable.type1
                              comp_efps = old_comparable.extractions_extraction_forms_projects_section.extraction_forms_projects_section
                              comp_eefps = self.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section: comp_efps)
                              comp_eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by(extractions_extraction_forms_projects_section: comp_eefps, type1: comp_t1)
                              new_comparable_element = ComparableElement.create(comparable: comp_eefps_t1, comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1')
                              new_comparate = Comparate.create(comparate_group: new_comparate_group, comparable_element: new_comparable_element)
                            elsif old_comparable.instance_of? ExtractionsExtractionFormsProjectsSectionsType1RowColumn
                              comp_tn = old_comparable.timepoint_name
                              comp_eefps_t1_row_column = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_by(extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row, timepoint_name: comp_tn)
                              new_comparable_element = ComparableElement.create(comparable: comp_eefps_t1_row_column, comparable_type: 'ExtractionsExtractionFormsProjectsSectionsType1RowColumn')
                              new_comparate = Comparate.create(comparate_group: new_comparate_group, comparable_element: new_comparable_element)
                            end
                          end
                        end
                        cloned_c_hash[comparison_name] = clone_comp
                      end
                    end
                  end

                  rssm_hash[efps_id][type1_id][population_name_id][rss_type_id].each do |measure_id, extraction_arr|

                    ###check if the count is equal to the count of extraction
                    if extraction_arr.length != extractions.length
                      next
                    end


                    rssm = ResultStatisticSectionsMeasure.find_or_create_by(result_statistic_section_id: rss.id, measure_id: measure_id)
                    rssm_id = rssm.id.to_s
                    rss.result_statistic_sections_measures << rssm

                    case rss_type_id
                    #Descriptive Statistics
                    #TpsArmsRssm
                    when "1"
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |tp_name_id, three_tp_hash|
                        three_tp_hash.each do |is_baseline, three_tp_bl_hash|
                          three_tp_bl_hash.each do |t1_efps_id, three_tp_t1efps_hash|
                            three_tp_t1efps_hash.each do |t1_id, ex_arr|
                              if ex_arr.length == extractions.length
                                tp_name = TimepointName.find(tp_name_id)
                                tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_by(extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row, timepoint_name: tp_name, is_baseline: is_baseline)
                                t1_eefps = ExtractionsExtractionFormsProjectsSection.find_by(extraction: self, extraction_forms_projects_section_id: t1_efps_id)
                                t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by(extractions_extraction_forms_projects_section: t1_eefps, type1_id: t1_id)
                                tps_arms_rssm = TpsArmsRssm.find_or_create_by(result_statistic_sections_measure: rssm, timepoint: tp, extractions_extraction_forms_projects_sections_type1: t1)

                                result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][t1_efps_id][t1_id].each do |record_name, record_ex_arr|
                                  if record_ex_arr.length == extractions.length
                                    record = Record.find_or_create_by(recordable: tps_arms_rssm, recordable_type: 'TpsArmsRssm')
                                    if record.name.nil? or record.name == ""
                                      record.update( name: record_name )
                                    end
                                  end
                                end
                              end
                            end
                          end
                        end
                      end

                    #Between Arm Comparisons
                    #TpsComparisonsRssm
                    when "2"
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |tp_name_id, three_tp_hash|
                        three_tp_hash.each do |is_baseline, three_tp_bl_hash|
                          three_tp_bl_hash.each do |comparison_name, ex_arr|
                            if ex_arr.length == extractions.length
                              tp_name = TimepointName.find(tp_name_id)
                              tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_by(extractions_extraction_forms_projects_sections_type1_row: eefps_t1_row, timepoint_name: tp_name, is_baseline: is_baseline)
                              comparison = cloned_c_hash[comparison_name]
                              tps_comparisons_rssm = TpsComparisonsRssm.find_or_create_by(result_statistic_sections_measure: rssm, timepoint: tp, comparison: comparison)
                              result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][tp_name_id][is_baseline][comparison_name].each do |record_name, record_ex_arr|
                                if record_ex_arr.length == extractions.length
                                  record = Record.find_or_create_by(recordable: tps_comparisons_rssm, recordable_type: 'TpsComparisonsRssm')
                                  if record.name.nil? or record.name == ""
                                    record.update( name: record_name )
                                  end
                                end
                              end
                            end
                          end
                        end
                      end

                    # Within Arm Comparisons
                    # ComparisonsArmsRssm
                    when "3"
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |comparison_name, three_c_hash|
                        three_c_hash.each do |t1_efps_id, three_c_t1efps_hash|
                          three_c_t1efps_hash.each do |t1_id, ex_arr|
                            if ex_arr.length == extractions.length
                              comparison = cloned_c_hash[comparison_name]

                              t1_eefps = ExtractionsExtractionFormsProjectsSection.find_by(extraction: self, extraction_forms_projects_section_id: t1_efps_id)
                              t1_name = Type1.find(t1_id)
                              t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_by(extractions_extraction_forms_projects_section: t1_eefps, type1: t1_name)

                              comparisons_arms_rssm = ComparisonsArmsRssm.find_or_create_by(result_statistic_sections_measure: rssm, comparison: comparison, extractions_extraction_forms_projects_sections_type1: t1)
                              result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][comparison_name][t1_efps_id][t1_id].each do |record_name, record_ex_arr|
                                if record_ex_arr.length == extractions.length
                                  record = Record.find_or_create_by( recordable: comparisons_arms_rssm, recordable_type: 'ComparisonsArmsRssm' )
                                  if record.name.nil? or record.name == ""
                                    record.update( name: record_name )
                                  end
                                end
                              end
                            end
                          end
                        end
                      end
                    when "4"
                      #NET Change
                      #WacsBacsRssm
                      three_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id].each do |wac_name, three_wac_hash|
                        three_wac_hash.each do |bac_name, ex_arr|
                          if ex_arr.length == extractions.length
                            wac = cloned_c_hash[wac_name]
                            bac = cloned_c_hash[bac_name]

                            wacs_bacs_rssm = WacsBacsRssm.find_or_create_by(result_statistic_sections_measure: rssm, wac: wac, bac: bac)
                            result_r_hash[efps_id][type1_id][population_name_id][rss_type_id][measure_id][wac_name][bac_name].each do |record_name, record_ex_arr|
                              if record_ex_arr.length == extractions.length
                                record = Record.find_or_create_by( recordable: wacs_bacs_rssm, recordable_type: 'WacsBacsRssm' )
                                if record.name.nil? or record.name == ""
                                  record.update( name: record_name )
                                end
                              end
                            end
                          end
                        end
                      end
                    else
                      # if rss_type is different than 1,2,3 or 4, jump into byebug
                    end
                  end
                end
              end
            end
          end
        end
      end

      # this is where we go down records hash and create the records for questions
      r_hash.each do |efps_id, r_efps_hash|
        r_efps_hash.each do |linked_efps_id, r_efps_linkedefps_hash|
          r_efps_linkedefps_hash.each do |t1_id, r_efps_linkedefps_t1_hash|
            r_efps_linkedefps_t1_hash.each do |t1_type_id, r_efps_linkedefps_t1_t1t_hash|
              r_efps_linkedefps_t1_t1t_hash.each do |qrcf_id, r_efps_linkedefps_t1_t1t_qrcf_hash|
                r_efps_linkedefps_t1_t1t_qrcf_hash.each do |record_name, r_es|
                  if r_es.uniq.length == extractions.length
                    linked_eefps = linked_efps_id.present? ? self.extractions_extraction_forms_projects_sections.find_by(extraction_forms_projects_section_id: linked_efps_id) : nil
                    eefps = self.extractions_extraction_forms_projects_sections.
                      find_by(extraction_forms_projects_section_id: efps_id,
                      link_to_type1: linked_eefps )
                    qrcf = QuestionRowColumnField.find(qrcf_id)
                    # what if type1 is nil
                    t1 = t1_id.present? ? Type1.find(t1_id) : nil
                    t1_type = t1_type_id.present? ? Type1Type.find(t1_type_id) : nil
                    eefps_t1 = t1.present? ? ExtractionsExtractionFormsProjectsSectionsType1.find_by(extractions_extraction_forms_projects_section: linked_eefps, type1: t1, type1_type: t1_type) : nil
                    #we want  to change find_or_create_by into  find_by asap
                    eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by(extractions_extraction_forms_projects_section: eefps, extractions_extraction_forms_projects_sections_type1: eefps_t1,  question_row_column_field: qrcf)
                    record = Record.find_or_create_by(recordable: eefps_qrcf, recordable_type: eefps_qrcf.class.name)
                    if (record.name.nil? or record.name == "") and not (record_name == nil or record_name == "")
                      record.update( name: record_name.dup.to_s )
                    end
                  end
                end
              end
            end
          end
        end
      end

    end
  end

  class_methods do
  end
end
