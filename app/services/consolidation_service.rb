class ConsolidationService
  def self.results(efps, citations_project, result_statistic_section_type_id)
    return {} unless efps.extraction_forms_projects_section_type.name == 'Results'

    extractions = Extraction.includes(projects_users_role: { projects_user: :user }).where(citations_project:)

    master_template = {
      1 => {},
      2 => {}
    }
    outcome_arm_check = {}
    results_lookup = {}
    dimensions_lookup = {}
    extractions.each do |extraction|
      dimensions_lookup[extraction.id] = {
        type1_type_type1: {},
        population: {},
        arm_comparison: {},
        timepoint_comparison: {},
        measure: {}
      }
    end

    eefpss =
      ExtractionsExtractionFormsProjectsSection
      .includes(
        {
          extraction: :user,
          extraction_forms_projects_section: :section,
          extractions_extraction_forms_projects_sections_type1s: [
            :type1,
            :type1_type,
            { extractions_extraction_forms_projects_sections_type1_rows: [
              :population_name,
              {
                extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name,
                result_statistic_sections: { result_statistic_sections_measures: [
                  :measure,
                  { tps_arms_rssms: [
                    :records,
                    { timepoint: :timepoint_name,
                      extractions_extraction_forms_projects_sections_type1: [
                        :type1,
                        { extractions_extraction_forms_projects_section: :extraction }
                      ] }
                  ] }
                ] }
              }
            ] }
          ]
        }
      )
      .where(extractions:, extraction_forms_projects_sections: { sections: { name: %w[Arms Outcomes] } })

    eefpss.each do |eefps|
      eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
        next unless eefps.extraction_forms_projects_section.section.name == 'Outcomes'

        outcome_arm_check["#{eefps.extraction_id}/#{eefpst1.type1_type.id}/#{eefpst1.type1.id}"] = true
        dimensions_lookup[eefps.extraction_id][:type1_type_type1]["#{eefpst1.type1_type.id}/#{eefpst1.type1.id}"] = true

        master_template[eefpst1.type1_type.id][eefpst1.type1.id] ||= {
          name: eefpst1.type1.name,
          description: eefpst1.type1.description,
          populations: {}
        }
        eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
          master_template[eefpst1.type1_type.id][eefpst1.type1.id][:populations][eefpst1r.population_name.id] ||= {
            name: eefpst1r.population_name.name,
            description: eefpst1r.population_name.description,
            timepoints: {},
            arms: {},
            measures: {}
          }
          dimensions_lookup[eefps.extraction_id][:population][eefpst1r.population_name.id] = true
          case result_statistic_section_type_id
          when 1, 2
            eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
              master_template[eefpst1.type1_type.id][eefpst1.type1.id][:populations][eefpst1r.population_name.id][:timepoints][eefpst1rc.timepoint_name.id] ||= {
                name: eefpst1rc.timepoint_name.name,
                unit: eefpst1rc.timepoint_name.unit
              }
              dimensions_lookup[eefps.extraction_id][:timepoint_comparison][eefpst1rc.timepoint_name.id] =
                true
            end
          when 3, 4
            rss = eefpst1r.within_arm_comparisons_section
            rss.comparisons.each do |comparison|
              consolidated_id = comparison.comparates.map do |comparate|
                comparate.comparable_element.comparable.timepoint_name.id
              end.join('/')
              master_template[eefpst1.type1_type.id][eefpst1.type1.id][:populations][eefpst1r.population_name.id][:timepoints][consolidated_id] ||= {
                name: comparison.comparates.map do |comparate|
                        comparate.comparable_element.comparable.timepoint_name.name
                      end.join(' vs '),
                unit: ''
              }
              dimensions_lookup[eefps.extraction_id][:timepoint_comparison][consolidated_id] = true
            end
          end
          eefpst1r.result_statistic_sections.each do |rss|
            next unless rss.result_statistic_section_type_id == result_statistic_section_type_id

            rss.result_statistic_sections_measures.each do |rssm|
              master_template[eefpst1.type1_type.id][eefpst1.type1.id][:populations][eefpst1r.population_name.id][:measures][rssm.measure.id] ||= {
                name: rssm.measure.name
              }
              dimensions_lookup[eefps.extraction_id][:measure][rssm.measure.id] = true
              population = rss.population
              timepoints = population.extractions_extraction_forms_projects_sections_type1_row_columns

              case result_statistic_section_type_id
              when 1
                eefpss.each do |second_eefps|
                  second_eefps.extractions_extraction_forms_projects_sections_type1s.each do |second_eefpst1|
                    next unless second_eefps.extraction_forms_projects_section.section.name == 'Arms' &&
                                second_eefps.extraction_id == eefps.extraction_id

                    timepoints.each do |eefpst1rc|
                      tps_arms_rssm = TpsArmsRssm.find_or_create_by(
                        result_statistic_sections_measure: rssm,
                        timepoint_id: eefpst1rc.id,
                        extractions_extraction_forms_projects_sections_type1_id: second_eefpst1.id
                      )
                      tps_arms_rssm.records.create! if tps_arms_rssm.records.blank?
                    end
                  end
                end
                rssm.tps_arms_rssms.each do |tps_arms_rssm|
                  extraction = eefps.extraction
                  type1_type = eefpst1.type1_type
                  outcome = eefpst1r.extractions_extraction_forms_projects_sections_type1.type1
                  population_name = eefpst1r.population_name
                  arm = tps_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1
                  timepoint_name = tps_arms_rssm.timepoint.timepoint_name
                  measure = rssm.measure
                  tps_arms_rssm.records.create! if tps_arms_rssm.records.blank?
                  record = tps_arms_rssm.records.first
                  results_lookup["#{extraction.id}-#{type1_type.id}-#{outcome.id}-#{population_name.id}-#{arm.id}-#{timepoint_name.id}-#{measure.id}"] = {
                    extraction_id: extraction.id,
                    type1_type_id: type1_type.id,
                    eefpst1_id: eefpst1.id,
                    tps_arms_rssm_id: tps_arms_rssm.id,
                    record_id: record.id,
                    record_value: record.name
                  }
                end
              when 2
                rss.comparisons.each do |comparison|
                  timepoints.each do |eefpst1rc|
                    tps_comparisons_rssm = TpsComparisonsRssm.find_or_create_by(
                      result_statistic_sections_measure: rssm,
                      timepoint_id: eefpst1rc.id,
                      comparison_id: comparison.id
                    )
                    tps_comparisons_rssm.records.create! if tps_comparisons_rssm.records.blank?
                  end
                end
                rssm.tps_comparisons_rssms.each do |tps_comparisons_rssm|
                  extraction = eefps.extraction
                  type1_type = eefpst1.type1_type
                  outcome = eefpst1r.extractions_extraction_forms_projects_sections_type1.type1
                  population_name = eefpst1r.population_name
                  consolidated_bac_id = tps_comparisons_rssm.comparison.comparates.map do |comparate|
                    comparate.comparable_element.comparable.type1.id
                  end.join('/')
                  timepoint_name = tps_comparisons_rssm.timepoint.timepoint_name
                  measure = rssm.measure
                  tps_comparisons_rssm.records.create! if tps_comparisons_rssm.records.blank?
                  record = tps_comparisons_rssm.records.first
                  results_lookup["#{extraction.id}-#{type1_type.id}-#{outcome.id}-#{population_name.id}-#{consolidated_bac_id}-#{timepoint_name.id}-#{measure.id}"] = {
                    extraction_id: extraction.id,
                    type1_type_id: type1_type.id,
                    eefpst1_id: eefpst1.id,
                    tps_arms_rssm_id: tps_comparisons_rssm.id,
                    record_id: record.id,
                    record_value: record.name
                  }
                end
              when 3
                eefpss.each do |second_eefps|
                  second_eefps.extractions_extraction_forms_projects_sections_type1s.each do |second_eefpst1|
                    next unless second_eefps.extraction_forms_projects_section.section.name == 'Arms' &&
                                second_eefps.extraction_id == eefps.extraction_id

                    rss.comparisons.each do |comparison|
                      comparisons_arms_rssm = ComparisonsArmsRssm.find_or_create_by(
                        result_statistic_sections_measure: rssm,
                        extractions_extraction_forms_projects_sections_type1: second_eefpst1,
                        comparison_id: comparison.id
                      )
                      comparisons_arms_rssm.records.create! if comparisons_arms_rssm.records.blank?
                    end
                  end
                end
                rssm.comparisons_arms_rssms.each do |comparisons_arms_rssm|
                  extraction = eefps.extraction
                  type1_type = eefpst1.type1_type
                  outcome = eefpst1r.extractions_extraction_forms_projects_sections_type1.type1
                  population_name = eefpst1r.population_name
                  arm = comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1.type1
                  consolidated_wac_id = comparisons_arms_rssm.comparison.comparates.map do |comparate|
                    comparate.comparable_element.comparable.timepoint_name.id
                  end.join('/')
                  measure = rssm.measure
                  comparisons_arms_rssm.records.create! if comparisons_arms_rssm.records.blank?
                  record = comparisons_arms_rssm.records.first
                  results_lookup["#{extraction.id}-#{type1_type.id}-#{outcome.id}-#{population_name.id}-#{arm.id}-#{consolidated_wac_id}-#{measure.id}"] = {
                    extraction_id: extraction.id,
                    type1_type_id: type1_type.id,
                    eefpst1_id: eefpst1.id,
                    comparisons_arms_rssm_id: comparisons_arms_rssm.id,
                    record_id: record.id,
                    record_value: record.name
                  }
                end
              when 4
                bac_rss = eefpst1r.between_arm_comparisons_section
                wac_rss = eefpst1r.within_arm_comparisons_section
                bac_rss.comparisons.each do |bac_comparison|
                  wac_rss.comparisons.each do |wac_comparison|
                    wacs_bacs_rssm = WacsBacsRssm.find_or_create_by(
                      result_statistic_sections_measure: rssm,
                      wac: wac_comparison,
                      bac: bac_comparison
                    )
                    wacs_bacs_rssm.records.create! if wacs_bacs_rssm.records.blank?
                  end
                end
                rssm.wacs_bacs_rssms.each do |wacs_bacs_rssm|
                  extraction = eefps.extraction
                  type1_type = eefpst1.type1_type
                  outcome = eefpst1r.extractions_extraction_forms_projects_sections_type1.type1
                  population_name = eefpst1r.population_name
                  consolidated_bac_id = wacs_bacs_rssm.bac.comparates.map do |comparate|
                    comparate.comparable_element.comparable.type1.id
                  end.join('/')
                  consolidated_wac_id = wacs_bacs_rssm.wac.comparates.map do |comparate|
                    comparate.comparable_element.comparable.timepoint_name.id
                  end.join('/')
                  measure = rssm.measure
                  wacs_bacs_rssm.records.create! if wacs_bacs_rssm.records.blank?
                  record = wacs_bacs_rssm.records.first
                  results_lookup["#{extraction.id}-#{type1_type.id}-#{outcome.id}-#{population_name.id}-#{consolidated_bac_id}-#{consolidated_wac_id}-#{measure.id}"] = {
                    extraction_id: extraction.id,
                    type1_type_id: type1_type.id,
                    eefpst1_id: eefpst1.id,
                    wacs_bacs_rssm_id: wacs_bacs_rssm.id,
                    record_id: record.id,
                    record_value: record.name
                  }
                end
              end
            end
          end
        end
      end
    end

    case result_statistic_section_type_id
    when 1, 3
      eefpss.each do |eefps|
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          next unless eefps.extraction_forms_projects_section.section.name == 'Arms'

          master_template.each do |type1_type_id, outcomes|
            outcomes.each do |type1_id, outcome|
              next unless outcome_arm_check["#{eefps.extraction_id}/#{type1_type_id}/#{type1_id}"]

              outcome[:populations].each do |population_name_id, _population|
                master_template[type1_type_id][type1_id][:populations][population_name_id][:arms][eefpst1.type1.id] ||= {
                  name: eefpst1.type1.name,
                  description: eefpst1.type1.description
                }
                dimensions_lookup[eefps.extraction_id][:arm_comparison][eefpst1.type1.id] = true
              end
            end
          end
        end
      end
    when 2, 4
      eefpss.each do |eefps|
        eefps.extractions_extraction_forms_projects_sections_type1s.each do |eefpst1|
          next unless eefps.extraction_forms_projects_section.section.name == 'Outcomes'

          eefpst1.extractions_extraction_forms_projects_sections_type1_rows.each do |eefpst1r|
            rss = eefpst1r.between_arm_comparisons_section
            rss.comparisons.each do |comparison|
              consolidated_id = comparison.comparates.map do |comparate|
                comparate.comparable_element.comparable.type1.id
              end.join('/')
              master_template[eefpst1.type1_type_id][eefpst1.type1_id][:populations][eefpst1r.population_name_id][:arms][consolidated_id] ||= {
                name: comparison.comparates.map do |comparate|
                        comparate.comparable_element.comparable.type1.name
                      end.join(' vs '),
                description: ''
              }
              dimensions_lookup[eefps.extraction_id][:arm_comparison][consolidated_id] = true
            end
          end
        end
      end
    end

    {
      master_template:,
      results_lookup:,
      dimensions_lookup:,
      extraction_ids: extractions.sort_by do |extraction|
                        extraction.consolidated ? 999_999_999 : extraction.id
                      end.map { |extraction| { id: extraction.id, user: extraction.user.email.split('@').first } },
      result_statistic_section_type_id:
    }
  end

  def self.suggestions(eefps_id)
    ExtractionsExtractionFormsProjectsSection.find(eefps_id).type1s_suggested_by_project_leads.map do |efpst1|
      t1 = {}
      t1[:name] = efpst1.type1.name
      t1[:description] = efpst1.type1.description
      t1[:type] = {}
      t1[:type][:id] = efpst1.type1_type.try(:id) || ''
      t1[:type][:name] = efpst1.type1_type.try(:name) || ''
      t1[:timepoints] = []
      efpst1.timepoint_names.each do |tn|
        t1[:timepoints] << { export_header: tn.pretty_print_export_header,
                             name: tn.name,
                             unit: tn.unit }
      end
      t1[:suggested_by] = efpst1.type1.suggestion.user.handle
      t1
    end
  end

  def self.efps_sections(project)
    ExtractionFormsProject.find_by(project:).extraction_forms_projects_sections.includes(:section).map do |efps|
      {
        efps_id: efps.id,
        name: efps.section.name
      }
    end
  end

  def self.efps(efps, citations_project)
    # error possiblities #
    # 1. link_to_type_1s may not mirror exactly between efps and eefps
    # 2. an efps may belong to efpst type 2 but have a link to another efps
    # 3. what if point 2 happens to an eefps i.e. a efps of type1 but with an eefps with a linked eefps

    mh = {
      efps: {},
      eefps: {},
      questions: [],
      current_citations_project: {}
    }
    qrcf_lookups = {}
    extractions_lookup = {}
    project = citations_project.project

    extractions = Extraction.includes(projects_users_role: { projects_user: :user }).where(citations_project:)
    extractions.each do |extraction|
      extractions_lookup[extraction.id] = extraction.user.email.split('@').first
    end
    efpss = ExtractionFormsProject
            .find_by(project:)
            .extraction_forms_projects_sections
            .includes(:section, :extraction_forms_projects_section_option)

    efpss.each do |iefps|
      efpso = if iefps.extraction_forms_projects_section_option.present?
                iefps.extraction_forms_projects_section_option
              else
                ExtractionFormsProjectsSectionOption.find_or_create_by(extraction_forms_projects_section: iefps)
              end
      efpso = { by_type1: efpso.by_type1, include_total: efpso.include_total }
      mh[:efps][iefps.id] = {
        data_type: 'efps',
        section_id: iefps.section_id,
        section_name: iefps.section.name,
        efpst_id: iefps.extraction_forms_projects_section_type_id,
        efpso:
      }
    end

    eefpss = ExtractionsExtractionFormsProjectsSection
             .where(extraction: extractions, extraction_forms_projects_section: efpss)
             .includes(:extraction)
             .uniq { |ieefpss| [ieefpss.extraction_id, ieefpss.extraction_forms_projects_section_id] }
    current_section_eefpss = eefpss.select { |eefps| eefps.extraction_forms_projects_section_id == efps.id }
    current_section_eefpss.sort_by! { |eefps| eefps.extraction.consolidated ? 999_999_999 : eefps.extraction.id }

    consolidated_extraction_eefps = current_section_eefpss.last
    consolidated_extraction_eefps_id = consolidated_extraction_eefps.id
    consolidated_extraction_eefpst1s = consolidated_extraction_eefps
                                       .extractions_extraction_forms_projects_sections_type1s
                                       .includes(
                                         :type1,
                                         :type1_type,
                                         {
                                           extractions_extraction_forms_projects_sections_type1_rows: [
                                             :population_name,
                                             { extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name }
                                           ]
                                         }
                                       )
    consolidated_extraction_eefpst1s = consolidated_extraction_eefpst1s.map do |consolidated_extraction_eefpst1|
      eefpst1rs = consolidated_extraction_eefpst1.extractions_extraction_forms_projects_sections_type1_rows
      populations = []
      timepoints = []
      eefpst1rs.sort_by { |eefpst1r| eefpst1r.id }.each do |eefpst1r|
        populations << eefpst1r.population_name.as_json.merge(eefpst1r_id: eefpst1r.id)
      end
      if eefpst1rs.present?
        eefpst1rs.first.extractions_extraction_forms_projects_sections_type1_row_columns.sort_by do |eefpst1rc|
          eefpst1rc.id
        end.each do |eefpst1rc|
          timepoints << eefpst1rc.timepoint_name.as_json.merge(eefpst1rc_id: eefpst1rc.id,
                                                               eefpst1r_id: eefpst1rc.extractions_extraction_forms_projects_sections_type1_row_id)
        end
      end
      {
        id: consolidated_extraction_eefpst1.id,
        type1_type_name: consolidated_extraction_eefpst1&.type1_type&.name,
        name: consolidated_extraction_eefpst1.type1.name,
        description: consolidated_extraction_eefpst1.type1.description,
        ordering_id: consolidated_extraction_eefpst1.id,
        pos: consolidated_extraction_eefpst1.pos,
        populations:,
        timepoints:
      }
    end

    current_section_eefpst1s = []
    current_section_eefpst1_objects = []

    # to do: check if we need eefpss or current_section_eefpss
    current_section_eefpss.each do |eefps|
      efps_id = eefps.extraction_forms_projects_section_id
      next if efps_id != efps.id

      extraction = eefps.extraction
      parent_eefps_id = eefps.link_to_type1&.id
      section_id = mh[:efps][efps_id][:section_id]
      section_name = mh[:efps][efps_id][:section_name]
      efpso = mh[:efps][efps_id][:efpso]
      if efps.extraction_forms_projects_section_type_id == 1
        parent_eefps = eefps
      elsif efps.extraction_forms_projects_section_type_id == 2
        parent_eefps = eefpss.find { |ieefps| ieefps.id == parent_eefps_id }
      end
      by_type1 = efpso[:by_type1]
      include_total = efpso[:include_total]
      parent_eefps_eefpst1s =
        if efps.extraction_forms_projects_section_type_id == 1
          parent_eefps.extractions_extraction_forms_projects_sections_type1s.includes(
            :type1,
            :type1_type,
            {
              extractions_extraction_forms_projects_sections_type1_rows: [
                :population_name,
                { extractions_extraction_forms_projects_sections_type1_row_columns: :timepoint_name }
              ]
            }
          )
        elsif parent_eefps.nil?
          []
        elsif by_type1 && include_total && parent_eefps.eefpst1s_without_total.count > 1
          parent_eefps.eefpst1s_with_total
        elsif by_type1
          parent_eefps.eefpst1s_without_total
        elsif !by_type1 && include_total
          parent_eefps.eefpst1s_only_total
        else
          []
        end
      parent_eefps_eefpst1s = parent_eefps_eefpst1s.map do |eefpst1|
        eefpst1rs = eefpst1.extractions_extraction_forms_projects_sections_type1_rows
        populations = []
        timepoints = []
        eefpst1rs.each do |eefpst1r|
          populations << eefpst1r.population_name.as_json.merge(eefpst1r_id: eefpst1r.id)
        end
        if eefpst1rs.present?
          eefpst1rs.first.extractions_extraction_forms_projects_sections_type1_row_columns.each do |eefpst1rc|
            timepoints << eefpst1rc.timepoint_name.as_json.merge(eefpst1rc_id: eefpst1rc.id,
                                                                 eefpst1r_id: eefpst1rc.extractions_extraction_forms_projects_sections_type1_row_id)
          end
        end
        { extractions_extraction_forms_projects_sections_type1_id: eefpst1.id,
          extractions_extraction_forms_projects_section_id: eefps.id,
          type1_id: eefpst1.type1_id,
          name: eefpst1.type1.name,
          description: eefpst1.type1.description,
          type1_type_name: eefpst1&.type1_type&.name,
          populations:,
          timepoints: }
      end

      parent_eefps_eefpst1s.each do |eefpst1|
        current_section_eefpst1_objects << eefpst1
        type1_id = eefpst1[:type1_id]
        eefps_id = eefpst1[:extractions_extraction_forms_projects_section_id]
        populations = eefpst1[:populations]
        timepoints = eefpst1[:timepoints]

        if current_section_eefpst1s.any? { |current_section_eefpst1| current_section_eefpst1[:type1_id] == type1_id }
          current_section_eefpst1s.each do |current_section_eefpst1|
            next unless current_section_eefpst1[:type1_id] == type1_id

            current_section_eefpst1[:eefpst1_lookups][eefps_id] =
              eefpst1[:extractions_extraction_forms_projects_sections_type1_id]
            current_section_eefpst1[:population_lookups][eefps_id] = populations
            current_section_eefpst1[:timepoint_lookups][eefps_id] = timepoints
          end
        else
          current_section_eefpst1 = {}
          current_section_eefpst1[:type1_id] = type1_id
          current_section_eefpst1[:name] = eefpst1[:name]
          current_section_eefpst1[:description] = eefpst1[:description]
          current_section_eefpst1[:eefpst1_lookups] =
            { eefps_id => eefpst1[:extractions_extraction_forms_projects_sections_type1_id] }
          current_section_eefpst1[:population_lookups] = { eefps_id => populations }
          current_section_eefpst1[:timepoint_lookups] = { eefps_id => timepoints }
          current_section_eefpst1[:type1_type_name] = eefpst1[:type1_type_name]
          current_section_eefpst1s << current_section_eefpst1
        end
      end

      mh[:eefps][eefps.id] = {
        data_type: 'eefps',
        extraction_id: extraction.id,
        section_id:,
        section_name:,
        efps_id:,
        type_id: mh[:efps][eefps.extraction_forms_projects_section_id][:efpst_id],
        parent_eefps_id:,
        children_eefps_ids: eefps.link_to_type2s.map(&:id),
        efpso:
      }
    end

    qrcfs = []
    ffs = []

    efps
      .questions
      .includes(
        question_rows: {
          question_row_columns: [
            :question_row_column_type,
            :question_row_column_fields,
            { question_row_columns_question_row_column_options: :followup_field }
          ]
        }
      ).each do |question|
      question_hash = {
        question_id: question.id,
        name: question.name,
        description: question.description,
        rows: []
      }

      mh[:questions] << question_hash
      question.question_rows.each do |question_row|
        question_row_hash = {
          question_row_id: question_row.id,
          name: question_row.name,
          columns: []
        }
        question_hash[:rows] << question_row_hash
        question_row.question_row_columns.each do |question_row_column|
          type_name = question_row_column.question_row_column_type.name

          if type_name == 'numeric'
            equality_qrcf = question_row_column.question_row_column_fields.first
            qrcf = question_row_column.question_row_column_fields.second
            qrcfs << equality_qrcf
            qrcf_lookups[equality_qrcf.id] = {
              qrcf_id: equality_qrcf.id,
              type_name:
            }
          else
            qrcf = question_row_column.question_row_column_fields.first
          end

          qrcfs << qrcf
          qrcf_lookups[qrcf.id] = {
            qrcf_id: qrcf.id,
            type_name:
          }
          selection_options = []
          question_row_column.question_row_columns_question_row_column_options.each do |qrcqrco|
            ff = qrcqrco.followup_field
            ffs << ff if ff.present?
            followup_field_id = ff&.id
            if QuestionRowColumnType::OPTION_SELECTION_TYPES.include?(type_name)
              next unless qrcqrco.question_row_column_option_id == 1

              qrcqrco_json = qrcqrco.as_json
              qrcqrco_json['data_type'] = qrcqrco.class.to_s
              qrcqrco_json[:followup_field_id] = followup_field_id
              selection_options << qrcqrco_json
            elsif type_name == QuestionRowColumnType::TEXT
              next unless [2, 3].include?(qrcqrco.question_row_column_option_id)

              qrcqrco_json = qrcqrco.as_json
              qrcqrco_json[:followup_field_id] = followup_field_id
              selection_options << qrcqrco_json
            elsif type_name == QuestionRowColumnType::NUMERIC
              next unless [4, 5, 6].include?(qrcqrco.question_row_column_option_id)

              qrcqrco_json = qrcqrco.as_json
              qrcqrco_json[:followup_field_id] = followup_field_id
              selection_options << qrcqrco_json
            else
              false
            end
          end

          question_row_column_hash = {
            question_row_column_id: question_row_column.id,
            question_row_column_name: question_row_column.name,
            type_name:,
            selection_options:,
            qrcf:,
            equality_qrcf:
          }
          question_row_hash[:columns] << question_row_column_hash
        end
      end
    end

    available_eefpsqrcf_hash = {}
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.where(
      extractions_extraction_forms_projects_section: current_section_eefpss,
      question_row_column_field: qrcfs
    ).each do |available_eefpsqrcf|
      key = [
        available_eefpsqrcf.question_row_column_field_id,
        available_eefpsqrcf.extractions_extraction_forms_projects_section_id,
        available_eefpsqrcf.extractions_extraction_forms_projects_sections_type1_id
      ].join('-')
      available_eefpsqrcf_hash[key] = true
    end

    # ensure eefpsqrcf exist
    missing_eefpsqrcfs = []
    current_section_eefpss.each do |current_section_eefps|
      qrcfs.each do |qrcf|
        if current_section_eefpst1_objects.empty? && available_eefpsqrcf_hash["#{qrcf.id}-#{current_section_eefps.id}"].nil?
          missing_eefpsqrcfs << {
            extractions_extraction_forms_projects_section_id: current_section_eefps.id,
            question_row_column_field_id: qrcf.id
          }
        else
          current_section_eefpst1_objects.each do |current_section_eefpst1_object|
            key = [
              qrcf.id,
              current_section_eefps.id,
              current_section_eefpst1_object[:extractions_extraction_forms_projects_sections_type1_id]
            ].join('-')
            if current_section_eefps.id != current_section_eefpst1_object[:extractions_extraction_forms_projects_section_id] ||
               available_eefpsqrcf_hash[key].present?
              next
            end

            missing_eefpsqrcfs << {
              extractions_extraction_forms_projects_section_id: current_section_eefps.id,
              question_row_column_field_id: qrcf.id,
              extractions_extraction_forms_projects_sections_type1_id: current_section_eefpst1_object[:extractions_extraction_forms_projects_sections_type1_id]
            }
          end
        end
      end
    end

    if missing_eefpsqrcfs.present?
      # TODO: performance optimization
      # ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.insert_all(missing_eefpsqrcfs)
      missing_eefpsqrcfs.each do |obj|
        ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by(obj)
      end
    end

    eefpsqrcfs = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.where(
      extractions_extraction_forms_projects_section: current_section_eefpss,
      question_row_column_field: qrcfs
    )

    unless current_section_eefpst1_objects.empty?
      eefpst1_ids = current_section_eefpst1_objects.map do |current_section_eefpst1_object|
        current_section_eefpst1_object[:extractions_extraction_forms_projects_sections_type1_id]
      end
      eefpsqrcfs = eefpsqrcfs.where(extractions_extraction_forms_projects_sections_type1_id: eefpst1_ids)
    end

    # TODO: performance optimization
    eefpsffs = []
    current_section_eefpss.each do |eefps|
      ffs.each do |ff|
        if current_section_eefpst1_objects.empty?
          eefpsffs << ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by(
            extractions_extraction_forms_projects_section: eefps,
            followup_field: ff,
            extractions_extraction_forms_projects_sections_type1_id: nil
          )
        else
          current_section_eefpst1_objects.each do |eefpst1_obj|
            eefpsffs << ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by(
              extractions_extraction_forms_projects_section: eefps,
              followup_field: ff,
              extractions_extraction_forms_projects_sections_type1_id: eefpst1_obj[:extractions_extraction_forms_projects_sections_type1_id]
            )
          end
        end
      end
    end

    # ensure records exist
    eefpsqrcfs_with_missing_records =
      ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
      .joins('LEFT JOIN records ON eefps_qrcfs.id = records.recordable_id')
      .where(id: eefpsqrcfs.map(&:id))
      .where(records: { id: nil })

    if eefpsqrcfs_with_missing_records.present?
      # TODO: performance optimization
      # Record.insert_all(eefpsqrcfs_with_missing_records.map do |missing_eefpsqrcf|
      #                     { recordable_type: ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField,
      #                       recordable_id: missing_eefpsqrcf.id }
      #                   end)
      eefpsqrcfs_with_missing_records.each do |missing_eefpsqrcf|
        Record.find_or_create_by(recordable_type: ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField,
                                 recordable_id: missing_eefpsqrcf.id)
      end
    end

    eefpsffs.each do |eefpsff|
      Record.find_or_create_by(recordable: eefpsff)
    end

    cell_lookups = {}
    Record
      .includes(:recordable)
      .joins('INNER JOIN eefps_qrcfs ON eefps_qrcfs.id = records.recordable_id')
      .where(recordable_id: eefpsqrcfs.map(&:id))
      .where(recordable_type: ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField)
      .each do |record|
      begin
        name = JSON.parse(record.name)
      rescue JSON::ParserError, TypeError
        name = record.name
      end
      eefpsqrcf = record.recordable
      eefpst1_id = eefpsqrcf.extractions_extraction_forms_projects_sections_type1_id
      eefps_id = eefpsqrcf.extractions_extraction_forms_projects_section_id
      qrcf_id = eefpsqrcf.question_row_column_field_id

      cell_lookups["record_id-#{qrcf_id}-#{eefps_id}-#{eefpst1_id}"] = record.id

      if QuestionRowColumnType::CHECKBOX == qrcf_lookups[qrcf_id][:type_name] && name.instance_of?(Array)
        name.each do |id|
          cell_lookups["#{qrcf_id}-#{eefps_id}-#{eefpst1_id}-#{id}"] = { id: record.id, value: true }
        end
      elsif QuestionRowColumnType::SINGLE_OPTION_ANSWER_TYPES.include?(qrcf_lookups[qrcf_id][:type_name])
        cell_lookups["#{qrcf_id}-#{eefps_id}-#{eefpst1_id}-#{name}"] = { id: record.id, value: true }
      else
        cell_lookups["#{qrcf_id}-#{eefps_id}-#{eefpst1_id}"] = { id: record.id, value: name }
      end
    end

    Record.where(recordable: eefpsffs).each do |record|
      name = record.name
      eefpsff = record.recordable
      eefpst1_id = eefpsff.extractions_extraction_forms_projects_sections_type1_id
      eefps_id = eefpsff.extractions_extraction_forms_projects_section_id
      ff_id = eefpsff.followup_field_id
      cell_lookups["record_id-ff-#{ff_id}-#{eefps_id}-#{eefpst1_id}"] = record.id
      cell_lookups["ff-#{ff_id}-#{eefps_id}-#{eefpst1_id}"] = { id: record.id, value: name }
    end

    eefpsqrcfqrcqrco_lookups = {}
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption.where(
      extractions_extraction_forms_projects_sections_question_row_column_field: eefpsqrcfs
    ).each do |eefpsqrcfqrcqrco|
      eefpsqrcf = eefpsqrcfqrcqrco.extractions_extraction_forms_projects_sections_question_row_column_field
      eefps = eefpsqrcf.extractions_extraction_forms_projects_section
      eefpst1_id = eefpsqrcf.extractions_extraction_forms_projects_sections_type1&.id
      qrcf_id = eefpsqrcfqrcqrco.extractions_extraction_forms_projects_sections_question_row_column_field.question_row_column_field.id
      lookup_key = "#{qrcf_id}-#{eefps.id}-#{eefpst1_id}"
      eefpsqrcfqrcqrco_lookups[lookup_key] ||= []
      eefpsqrcfqrcqrco_lookups[lookup_key] << {
        id: eefpsqrcfqrcqrco.question_row_columns_question_row_column_option.id,
        name: eefpsqrcfqrcqrco.question_row_columns_question_row_column_option.name
      }
    end
    eefpsqrcfs.each do |eefpsqrcf|
      eefpsqrcfqrcqrco_lookups["eefps-#{eefpsqrcf.extractions_extraction_forms_projects_section_id}-qrcf-#{eefpsqrcf.question_row_column_field_id}"] =
        eefpsqrcf.id
    end

    citation = citations_project.citation
    current_section_eefpss.map! do |eefps|
      as_json = eefps.as_json
      as_json[:consolidated] = eefps.extraction.consolidated
      as_json
    end
    mh[:current_section_statusing_id] =
      ExtractionsExtractionFormsProjectsSection.find(current_section_eefpss.last['id']).statusing.id
    mh[:current_section_status_id] =
      ExtractionsExtractionFormsProjectsSection.find(current_section_eefpss.last['id']).statusing.status_id
    mh[:current_citations_project] = {
      project_id: project.id,
      citation_id: citation.id,
      citations_project_id: citations_project.id,
      efps_id: efps.id,
      efpst_id: efps.extraction_forms_projects_section_type_id,
      section_name: efps.section.name,
      current_section_eefpst1s:,
      current_section_eefpss:,
      by_arms:
        efps.link_to_type1.present? &&
        (mh[:efps][efps.id][:efpso][:by_type1] || mh[:efps][efps.id][:efpso][:include_total]).present?,
      cell_lookups:,
      extractions_lookup:,
      eefpsqrcfqrcqrco_lookups:,
      consolidated_extraction_eefpst1s:,
      consolidated_extraction_eefps_id:
    }
    mh
  end

  def self.project_citations_grouping_hash(project)
    citations_grouping_hash = {}
    citations_projects = project.citations_projects
    extractions =
      project
      .extractions
      .includes(
        :extraction_checksum,
        statusing: :status,
        citations_project: { citation: :journal }
      )
    citations_projects.each do |citations_project|
      citations_grouping_hash[citations_project.id] = {
        extractions: [],
        consolidated_extraction: nil,
        citation_title: "#{citations_project.citation.authors}: #{citations_project.citation.name}",
        citation_year: citations_project.citation.journal&.get_publication_year,
        reference_checksum: nil,
        differences: false,
        consolidated_extraction_status: nil
      }
    end

    extractions.each do |extraction|
      if extraction.consolidated
        citations_grouping_hash[extraction.citations_project_id][:consolidated_extraction] = extraction
        citations_grouping_hash[extraction.citations_project_id][:consolidated_extraction_status] =
          extraction.status.name
      else
        citations_grouping_hash[extraction.citations_project_id][:extractions] << extraction
        checksum = extraction.extraction_checksum
        checksum.update_hexdigest if checksum.is_stale
        citations_grouping_hash[extraction.citations_project_id][:reference_checksum] ||= checksum.hexdigest
        if citations_grouping_hash[extraction.citations_project_id][:reference_checksum] != checksum.hexdigest
          citations_grouping_hash[extraction.citations_project_id][:differences] = true
        end
      end
    end
    citations_grouping_hash
  end
end
