class ExtractionSupplyingService

  def find_by_project_id(id)
    project = Project.includes(:extractions).find(id)
    extractions = project.extractions.map { |extraction| find_by_extraction_id(extraction.id) }
    extractions = extractions.select { |element| !element["entry"].empty? }

    link_info = [
      {
        'relation' => 'tag',
        'url' => "api/v3/projects/#{id}/extractions"
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/extraction.txt'
      }
    ]
    full_urls = FhirResourceService.build_full_url(resources: extractions, relative_path: 'extractions/')
    bundle = FhirResourceService.get_bundle(fhir_objs: extractions, type: 'collection', link_info: link_info, full_urls: full_urls)

    bundle
  end

  def find_by_extraction_id(id)
    extraction = Extraction.includes(
      extractions_extraction_forms_projects_sections: [
        :extraction_forms_projects_section,
        { status: :statusings },
        { extractions_extraction_forms_projects_sections_type1s:
          [:type1, :extractions_extraction_forms_projects_sections_type1_rows, { status: :statusings }] },
        { extractions_extraction_forms_projects_sections_followup_fields: :followup_field },
        { extractions_extraction_forms_projects_sections_question_row_column_fields:
          [
            :extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options,
            { question_row_column_field:
              { question_row_column: [:question_row_columns_question_row_column_options, :question_row_column_type] } },
            :records
          ]
        }
      ]
    ).find(id)

    # extraction_sections = extraction.extraction_forms_projects_sections.first.extraction_forms_project.extraction_forms_projects_sections.flat_map do |efps|
    #   efps.extractions_extraction_forms_projects_sections.select { |eefps| eefps.extraction_id == id.to_i }
    # end

    fhir_extraction_sections = extraction.extractions_extraction_forms_projects_sections.map { |extraction_section| create_fhir_obj(extraction_section) }.flatten

    fhir_list = FhirResourceService.get_list(fhir_objs: fhir_extraction_sections)
    fhir_list['identifier'] = FhirResourceService.build_identifier('Extraction', id)[0]
    fhir_list['id'] = "13-#{id}"

    fhir_list
  end

  private

  def create_fhir_obj(raw)
    form = ExtractionFormsProjectsSection.find(raw.extraction_forms_projects_section_id)

    case form.extraction_forms_projects_section_type_id
    when 2
      case raw.status['name']
      when 'Draft'
        status = 'in-progress'
      when 'Completed'
        status = 'completed'
      end

      linkid_hash = build_linkid_hash(raw)
      eefpss = []
      eefpsqrcf_grouped_by_type1 = raw.extractions_extraction_forms_projects_sections_question_row_column_fields.group_by { |item| item["extractions_extraction_forms_projects_sections_type1_id"] }
      eefpsqrcf_grouped_by_type1.each do |eefps_type1_id, eefpsqrcfs|
        eefps_items = []
        restriction_symbol = ''
        eefpsqrcfs.each do |eefpsqrcf|
          question_row_column = eefpsqrcf.question_row_column_field.question_row_column
          ans_form = question_row_column.question_row_columns_question_row_column_options
          type = question_row_column.question_row_column_type.id
          eefps_item_linkid = linkid_hash[eefpsqrcf.id]

          value = eefpsqrcf.records.present? ? eefpsqrcf.records[0]['name'] : ''
          value = nil if value.is_a?(String) && value.empty?
          next if value.nil? && type != 9

          followups = get_followups(raw)

          case type
          when 1
            eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: value)
          when 2
            if /-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?/.match(value)
              eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: value.to_f, value_type: 'valueDecimal')
              unless restriction_symbol.empty?
                eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: restriction_symbol)
              end
              restriction_symbol = ''
            else
              restriction_symbol = value
            end
          when 5
            matches = value.scan(/\D*(\d+)\D*/)
            matches.each do |match|
              checkbox_id = match[0].to_i
              checkbox = ans_form.find_by(id: checkbox_id)
              next unless checkbox

              followup_items = nil
              if followups.has_key?(checkbox_id)
                followup_items = [FhirResourceService.build_questionnaire_response_item(linkid: "#{eefps_item_linkid}-#{followups[checkbox_id]['id']}", value: followups[checkbox_id]['name'])]
              end

              eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: checkbox['name'], item: followup_items)
            end
          when 6
            eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: ans_form.find(value)['name'])
          when 7
            followup_items = nil
            if followups.has_key?(value.to_i)
              followup_items = [FhirResourceService.build_questionnaire_response_item(linkid: "#{eefps_item_linkid}-#{followups[value.to_i]['id']}", value: followups[value.to_i]['name'])]
            end
            eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: ans_form.find(value)['name'], item: followup_items)
          when 8
            eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: ans_form.find(value)['name'])
          when 9
            eefpsqrcf.extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options.each do |dicts|
              value = dicts.question_row_columns_question_row_column_option_id
              eefps_items << FhirResourceService.build_questionnaire_response_item(linkid: eefps_item_linkid, value: ans_form.find(value)['name'])
            end
          end
        end

        next if eefps_items.empty?

        merged_items = merge_questionnaire_response_items(eefps_items)
        eefps = create_eefps(form, raw, status, eefps_type1_id, eefpsqrcf_grouped_by_type1, form.id, merged_items)
        next if eefps.nil?

        eefpss << eefps
      end

      if eefpss.empty?
        return
      end

      return eefpss

    when 3
      extraction = Extraction.includes(
        :project,
        extraction_forms_projects_sections: {
          extraction_forms_project: :extraction_forms_project_type
        }
      ).find(raw.extraction_id)
      project = Project.find(extraction.project_id)
      efp_type_id = extraction.extraction_forms_projects_sections.first.extraction_forms_project.extraction_forms_project_type_id
      if efp_type_id == 1
        outcomes = ExtractionsExtractionFormsProjectsSectionsType1.includes(
          :type1,
          extractions_extraction_forms_projects_sections_type1_rows:[
            :population_name,
            result_statistic_sections: {
              result_statistic_sections_measures: [
                :measure,
                tps_arms_rssms: [:records, :timepoint],
                tps_comparisons_rssms: [
                  :records,
                  :timepoint,
                  comparison: { comparate_groups: :comparable_elements }
                ],
                comparisons_arms_rssms: [
                  :records,
                  comparison: { comparate_groups: :comparable_elements }
                ],
                wacs_bacs_rssms: [
                  :records,
                  wac: { comparate_groups: :comparable_elements },
                  bac: { comparate_groups: :comparable_elements }
                ]
              ]
            }
          ]
        ).by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Outcomes',
          raw.extraction_id,
          project.extraction_forms_projects.first.id
        )
        evidences = []

        outcomes.each do |outcome|
          case outcome.status['name']
          when 'Draft'
            outcome_status = 'draft'
          when 'Completed'
            outcome_status = 'active'
          end

          outcome_name = outcome.type1['name']
          populations = outcome.extractions_extraction_forms_projects_sections_type1_rows

          populations.each do |population|
            population_name = population.population_name['name']
            result_statistic_sections = population.result_statistic_sections

            [0, 1, 2, 3].each do |sec_num|
              case sec_num
              when 0
                result_statistic_sections[sec_num].result_statistic_sections_measures.each do |result_statistic_sections_measure|
                  measure_name = result_statistic_sections_measure.measure['name']
                  result_statistic_sections_measure.tps_arms_rssms.each do |tps_arms_rssm|
                    record, record_id = get_record_and_id(tps_arms_rssm)
                    next if record.nil?

                    time_point_name = get_time_point_name(tps_arms_rssm.timepoint_id)
                    next if time_point_name.nil?

                    arm_name = get_arm_name(tps_arms_rssm.extractions_extraction_forms_projects_sections_type1_id)
                    next if arm_name.nil?

                    evidence = get_evidence_obj(
                      record_id,
                      outcome_status,
                      population_name,
                      [arm_name],
                      outcome_name,
                      [time_point_name],
                      record,
                      measure_name
                    )

                    evidences << evidence
                  end
                end
              when  1
                result_statistic_sections[sec_num].result_statistic_sections_measures.each do |result_statistic_sections_measure|
                  measure_name = result_statistic_sections_measure.measure['name']
                  result_statistic_sections_measure.tps_comparisons_rssms.each do |tps_comparisons_rssm|
                    record, record_id = get_record_and_id(tps_comparisons_rssm)
                    next if record.nil?

                    time_point_name = get_time_point_name(tps_comparisons_rssm.timepoint_id)
                    next if time_point_name.nil?

                    comparison = tps_comparisons_rssm.comparison
                    next if comparison.blank?

                    arm_names = []
                    comparison.comparate_groups.each do |comparate_group|
                      comparable_elements = comparate_group.comparable_elements
                      arm_name_in_same_comparate_group = []
                      comparable_elements.each do |comparable_element|
                        arm_name = get_arm_name(comparable_element.comparable_id)
                        arm_name_in_same_comparate_group << arm_name
                      end
                      arm_names << arm_name_in_same_comparate_group
                    end

                    evidence = get_evidence_obj(
                      record_id,
                      outcome_status,
                      population_name,
                      arm_names,
                      outcome_name,
                      [time_point_name],
                      record,
                      measure_name
                    )

                    evidences << evidence
                  end
                end
              when 2
                result_statistic_sections[sec_num].result_statistic_sections_measures.each do |result_statistic_sections_measure|
                  measure_name = result_statistic_sections_measure.measure['name']
                  result_statistic_sections_measure.comparisons_arms_rssms.each do |comparisons_arms_rssm|
                    record, record_id = get_record_and_id(comparisons_arms_rssm)
                    next if record.nil?

                    comparison = comparisons_arms_rssm.comparison
                    next if comparison.blank?

                    time_point_names = []
                    comparison.comparate_groups.each do |comparate_group|
                      comparable_elements = comparate_group.comparable_elements
                      if !comparable_elements.blank?
                        time_point_name = get_time_point_name(comparable_elements[0].comparable_id)
                        time_point_names << time_point_name
                      end
                    end

                    arm_name = get_arm_name(comparisons_arms_rssm.extractions_extraction_forms_projects_sections_type1_id)
                    next if arm_name.nil?

                    evidence = get_evidence_obj(
                      record_id,
                      outcome_status,
                      population_name,
                      [arm_name],
                      outcome_name,
                      time_point_names,
                      record,
                      measure_name
                    )

                    evidences << evidence
                  end
                end
              when 3
                result_statistic_sections[sec_num].result_statistic_sections_measures.each do |result_statistic_sections_measure|
                  measure_name = result_statistic_sections_measure.measure['name']
                  result_statistic_sections_measure.wacs_bacs_rssms.each do |wacs_bacs_rssm|
                    record, record_id = get_record_and_id(wacs_bacs_rssm)
                    next if record.nil?

                    comparison_arm = wacs_bacs_rssm.bac
                    next if comparison_arm.blank?

                    arm_names = []
                    comparison_arm.comparate_groups.each do |comparate_group|
                      comparable_elements = comparate_group.comparable_elements
                      arm_name_in_same_comparate_group = []
                      comparable_elements.each do |comparable_element|
                        arm_name = get_arm_name(comparable_element.comparable_id)
                        arm_name_in_same_comparate_group << arm_name
                      end
                      arm_names << arm_name_in_same_comparate_group
                    end

                    comparison_time_point = wacs_bacs_rssm.wac
                    next if comparison_time_point.blank?

                    time_point_names = []
                    comparison_time_point.comparate_groups.each do |comparate_group|
                      comparable_elements = comparate_group.comparable_elements
                      if !comparable_elements.blank?
                        time_point_name = get_time_point_name(comparable_elements[0].comparable_id)
                        time_point_names << time_point_name
                      end
                    end

                    evidence = get_evidence_obj(
                      record_id,
                      outcome_status,
                      population_name,
                      arm_names,
                      outcome_name,
                      time_point_names,
                      record,
                      measure_name
                    )

                    evidences << evidence
                  end
                end
              end
            end
          end
        end

        if evidences.blank?
          return
        else
          merged_evidences = merge_evidence_by_variable_definition(evidences)
          merged_evidences = merge_statistics(merged_evidences)
          merged_evidences = FhirResourceService.deep_clean(merged_evidences)

          return merged_evidences
        end

      else
        outcomes = ExtractionsExtractionFormsProjectsSectionsType1.includes(
          :type1,
          extractions_extraction_forms_projects_sections_type1_rows:[
            :population_name,
            result_statistic_sections: {
              result_statistic_sections_measures: [
                :measure,
                tps_arms_rssms: [:records, :timepoint],
                tps_comparisons_rssms: [
                  :records,
                  :timepoint,
                  comparison: { comparate_groups: :comparable_elements }
                ],
                comparisons_arms_rssms: [
                  :records,
                  comparison: { comparate_groups: :comparable_elements }
                ],
                wacs_bacs_rssms: [
                  :records,
                  wac: { comparate_groups: :comparable_elements },
                  bac: { comparate_groups: :comparable_elements }
                ]
              ]
            }
          ]
        ).by_section_name_and_extraction_id_and_extraction_forms_project_id(
          'Diagnoses',
          raw.extraction_id,
          project.extraction_forms_projects.first.id
        )
        evidences = []

        outcomes.each do |outcome|
          case outcome.status['name']
          when 'Draft'
            outcome_status = 'draft'
          when 'Completed'
            outcome_status = 'active'
          end

          outcome_name = outcome.type1['name']
          populations = outcome.extractions_extraction_forms_projects_sections_type1_rows

          populations.each do |population|
            population_name = population.population_name['name']
            result_statistic_sections = population.result_statistic_sections

            [4, 5, 6, 7].each do |sec_num|
              result_statistic_sections[sec_num].result_statistic_sections_measures.each do |result_statistic_sections_measure|
                measure_name = result_statistic_sections_measure.measure['name']
                result_statistic_sections_measure.tps_comparisons_rssms.each do |tps_comparisons_rssm|
                  record, record_id = get_record_and_id(tps_comparisons_rssm)
                  next if record.nil?

                  time_point_name = get_time_point_name(tps_comparisons_rssm.timepoint_id)
                  next if time_point_name.nil?

                  comparison = Comparison.find_by(id: tps_comparisons_rssm.comparison_id)
                  next if comparison.blank?

                  arm_names = []
                  comparison.comparate_groups.each do |comparate_group|
                    comparable_elements = comparate_group.comparable_elements
                    arm_name_in_same_comparate_group = []
                    comparable_elements.each do |comparable_element|
                      arm_name = get_arm_name(comparable_element.comparable_id)
                      arm_name_in_same_comparate_group << arm_name
                    end
                    arm_names << arm_name_in_same_comparate_group
                  end

                  evidence = get_evidence_obj(
                    record_id,
                    outcome_status,
                    population_name,
                    arm_names,
                    outcome_name,
                    [time_point_name],
                    record,
                    measure_name
                  )

                  evidences << evidence
                end
              end
            end
          end
        end

        if evidences.blank?
          return
        else
          merged_evidences = merge_evidence_by_variable_definition(evidences)
          merged_evidences = merge_statistics(merged_evidences)
          merged_evidences = FhirResourceService.deep_clean(merged_evidences)

          return merged_evidences
        end
      end
    end
  end

  def get_record_and_id(rssm)
    record = rssm.records[0]
    return nil if record.blank?
    return nil if record['name'].blank?

    record_id = rssm.records[0]['id']
    record = record['name']
    return record, record_id
  end

  def get_time_point_name(timepoint_id)
    time_point = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_by(id: timepoint_id)
    return nil if time_point.blank?

    time_point_name = time_point.timepoint_name['name'] + ' ' + time_point.timepoint_name['unit']
    return time_point_name
  end

  def get_arm_name(arm_id)
    arm = ExtractionsExtractionFormsProjectsSectionsType1.find_by(id: arm_id)
    return nil if arm.blank?

    arm_name = Type1.find(arm.type1_id)['name']
    return arm_name
  end

  def merge_evidence_by_variable_definition(evidences)
    grouped_evidences = evidences.group_by { |e| e['variableDefinition'].to_json }

    merged_evidences = []

    grouped_evidences.each do |_, group|
      merged_resource = group.first.deep_dup

      group[1..-1].each do |resource|
        if resource['id'] && resource['statistic'] && resource['identifier']
          merged_resource['id'] += "-#{resource['id'].split('-').last}"
          merged_resource['statistic'] += resource['statistic']

          if resource['identifier'].first && resource['identifier'].first['value']
            merged_resource['identifier'].first['value'] += "-#{resource['identifier'].first['value'].split('/').last}"
          end
        end
      end

      merged_evidences << merged_resource
    end

    merged_evidences
  end

  def merge_statistics(array)
    array.map do |item|
      attribute_estimate_arr = []
      note_arr = []
      description_arr = []
      number_of_events = nil
      sample_size = nil

      merge_targets = []
      keep_targets = []

      item["statistic"].each do |statistic|
        if statistic.key?("statisticType")
          keep_targets << statistic
        else
          merge_targets << statistic
        end
      end

      merge_targets.each do |statistic|
        if statistic.key?("attributeEstimate")
          attribute_estimate_arr += statistic["attributeEstimate"]
          statistic.delete("attributeEstimate")
        end

        if statistic.key?("note")
          note_arr += statistic["note"]
          statistic.delete("note")
        end

        if statistic.key?("description")
          description_arr << statistic["description"]
          statistic.delete("description")
        end

        if statistic.key?("numberOfEvents")
          number_of_events ||= statistic["numberOfEvents"]
          statistic.delete("numberOfEvents")
        end

        if statistic.key?("sampleSize")
          sample_size ||= statistic["sampleSize"]
          statistic.delete("sampleSize")
        end
      end

      merged_statistic = merge_targets.reduce({}, :merge)

      if keep_targets.empty?
        if attribute_estimate_arr.any?
          merged_statistic["attributeEstimate"] = attribute_estimate_arr
        end

        if note_arr.any?
          merged_statistic["note"] = note_arr
        end

        merged_statistic["numberOfEvents"] = number_of_events if number_of_events
        merged_statistic["sampleSize"] = sample_size if sample_size
      else
        keep_targets.each do |statistic|
          if attribute_estimate_arr.any?
            if statistic.key?("attributeEstimate")
              statistic["attributeEstimate"] += attribute_estimate_arr
            else
              statistic["attributeEstimate"] = attribute_estimate_arr.dup
            end
          end

          if note_arr.any?
            if statistic.key?("note")
              statistic["note"] += note_arr
            else
              statistic["note"] = note_arr.dup
            end
          end

          statistic["numberOfEvents"] ||= number_of_events
          statistic["sampleSize"] ||= sample_size
        end
      end

      merged_statistic["description"] = description_arr.join(', ') unless description_arr.empty?

      item["statistic"].each do |statistic|
        if statistic.key?("attributeEstimate")
          groups = statistic["attributeEstimate"].group_by { |e| [e['type'], e['level']] }

          new_attribute_estimate = []

          groups.each do |key, group|
            if group.count { |e| e['range'] && e['range'].key?('low') } == 1 &&
               group.count { |e| e['range'] && e['range'].key?('high') } == 1 &&
               group.size == 2
              low_element = group.find { |e| e['range'].key?('low') }
              high_element = group.find { |e| e['range'].key?('high') }
              merged = low_element
              merged['range']['high'] = high_element['range']['high']
              new_attribute_estimate << merged
            else
              new_attribute_estimate.concat(group)
            end
          end

          statistic["attributeEstimate"] = new_attribute_estimate
        end
      end

      item["statistic"] = [merged_statistic] + keep_targets
      item
    end
  end

  def get_evidence_obj(
    record_id,
    outcome_status,
    population_name,
    arm_name_groups,
    outcome_name,
    time_point_names,
    record,
    measure_name
  )
    measure_name = measure_name.gsub(/\s+/, ' ').downcase.strip
    evidence = {
      'resourceType' => 'Evidence',
      'id' => "5-#{record_id}",
      'status' => outcome_status,
      'identifier' => FhirResourceService.build_identifier('Record', record_id),
      'variableDefinition' => [
        FhirResourceService.build_evidence_variable_definition(description: population_name, variable_role: 'population')
      ],
      'statistic' => [{}]
    }

    begin
      record = Float(record)

      case measure_name
      when 'total (n analyzed)'
        evidence['statistic'][0]['sampleSize'] = { 'knownDataCount' => record.to_i }
      when 'events'
        evidence['statistic'][0]['numberOfEvents'] = record.to_i
      when /95% ci low/
        evidence['statistic'][0]['attributeEstimate'] = [{
          'type' => {
            'coding' => [{
              'system' => 'http://terminology.hl7.org/CodeSystem/attribute-estimate-type',
              'code' => 'C53324',
              'display' => 'Confidence interval'
            }]
          },
          'level' => 0.95,
          'range' => {
            'low' => {
              'value' => record.to_f
            }
          }
        }]
      when /95% ci high/
        evidence['statistic'][0]['attributeEstimate'] = [{
          'type' => {
            'coding' => [{
              'system' => 'http://terminology.hl7.org/CodeSystem/attribute-estimate-type',
              'code' => 'C53324',
              'display' => 'Confidence interval'
            }]
          },
          'level' => 0.95,
          'range' => {
            'high' =>  {
              'value' => record.to_f
            }
          }
        }]
      when /p value/
        evidence['statistic'][0]['attributeEstimate'] = [{
          'type' => {
            'coding' => [{
              'system' => 'http://terminology.hl7.org/CodeSystem/attribute-estimate-type',
              'code' => 'C44185',
              'display' => 'P-value'
            }]
          },
          'quantity' => {
            'value' => record.to_f
          }
        }]
      when 'sd'
        evidence['statistic'][0]['attributeEstimate'] = [{
          'type' => {
            'coding' => [{
              'system' => 'http://terminology.hl7.org/CodeSystem/attribute-estimate-type',
              'code' => 'C53322',
              'display' => 'Standard deviation'
            }]
          },
          'quantity' => {
            'value' => record.to_f
          }
        }]
      else
        evidence['statistic'][0]['quantity'] = {'value' => record.to_f}
        evidence['statistic'][0]['description'] = "#{measure_name}: #{record}"
      end
    rescue ArgumentError
      evidence['statistic'][0]['note'] = [{'text' => "#{measure_name}: #{record}"}]
    end

    if arm_name_groups.length == 1 and !arm_name_groups[0].is_a?(Array)
      evidence['variableDefinition'] << FhirResourceService.build_evidence_variable_definition(description: arm_name_groups[0], variable_role: 'exposure')
    else
      arm_names_combined = []

      arm_name_groups.each_with_index do |arm_name_group, index|
        arm_name_group = [arm_name_group] unless arm_name_group.respond_to?(:each)

        combined_names = arm_name_group.join(", ")
        arm_names_combined << combined_names
      end

      description_for_exposure = arm_names_combined.first
      comparator_category = (arm_names_combined[1..] || []).join("; ")
      comparator_display = arm_names_combined.join(" vs ")

      evidence['variableDefinition'] << FhirResourceService.build_evidence_variable_definition(description: description_for_exposure, variable_role: 'exposure', comparator_category: comparator_category, comparator_display: comparator_display)
    end

    time_point_string = time_point_names.join(' - ')
    evidence['variableDefinition'] << FhirResourceService.build_evidence_variable_definition(description: "#{outcome_name}, #{time_point_string}", variable_role: 'outcome')

    statistic_type_mapping = {
      'proportion' => ['C44256', 'Proportion'],
      'incidence rate (per 1000)' => ['C16726', 'Incidence'],
      'incidence rate (per 10,000)' => ['C16726', 'Incidence'],
      'incidence rate (per 100,000)' => ['C16726', 'Incidence'],
      'odds ratio (or)' => ['C16932', 'Odds Ratio'],
      'odds ratio, adjusted (adjor)' => ['C16932', 'Odds Ratio'],
      'incidence rate ratio (irr)' => ['rate-ratio', 'Incidence Rate Ratio'],
      'incidence rate ratio, adjusted (adjirr)' => ['rate-ratio', 'Incidence Rate Ratio'],
      'hazard ratio (hr)' => ['C93150', 'Hazard Ratio'],
      'hazard ratio, adjusted (adjhr)' => ['C93150', 'Hazard Ratio'],
      'risk difference (rd)' => ['0000424', 'Risk Difference'],
      'risk difference, adjusted (adjrd)' => ['0000424', 'Risk Difference'],
      'risk ratio (rr)' => ['C93152', 'Relative Risk'],
      'mean' => ['C53319', 'Mean'],
      'mean difference (md)' => ['0000457', 'Mean Difference']
    }

    exact_exception_measure_names = ['total (n analyzed)', 'events', 'sd']
    partial_exception_measure_names = ['95% ci low', '95% ci high', 'p value']

    if statistic_type_mapping.key?(measure_name)
      code, display = statistic_type_mapping[measure_name]
      evidence['statistic'][0]['statisticType'] = {
        'coding' => [{
          'system' => 'http://terminology.hl7.org/CodeSystem/statistic-type',
          'code' => code,
          'display' => display
        }]
      }
    elsif !exact_exception_measure_names.include?(measure_name) && !partial_exception_measure_names.any? { |s| measure_name.include? s }
      evidence['statistic'][0]['statisticType'] = {
        'text' => measure_name
      }
    end

    evidence
  end

  def create_eefps(form, raw, status, eefps_type1_id, eefpsqrcf_grouped_by_type1, question_id, items)
    base_url = 'https://srdrplus.ahrq.gov/api/v3/extraction_forms_projects_sections/'
    all_blank = eefpsqrcf_grouped_by_type1.keys.all?(&:blank?)
    return nil if eefps_type1_id.blank? && !all_blank

    type1 = unless eefps_type1_id.blank?
              ExtractionsExtractionFormsProjectsSectionsType1.find_by(id: eefps_type1_id)&.type1
            end
    type1_id = type1 ? type1.id.to_s : 'none'
    type1_display = type1 ? "#{type1.name} (#{type1.description})" : nil

    FhirResourceService.get_questionnaire_response(
      id_prefix: 4,
      srdrplus_id: raw.id,
      srdrplus_type: 'ExtractionsExtractionFormsProjectsSection',
      status: status,
      type1_id: type1_id,
      questionnaire_url: "#{base_url}#{question_id}",
      items: items,
      type1_display: type1_display
    )
  end

  def get_followups(raw)
    followups = raw.extractions_extraction_forms_projects_sections_followup_fields.each_with_object({}) do |followup, hash|
      unless followup.records[0]['name'].blank?
        question_id = FollowupField.find(followup.followup_field_id).question_row_columns_question_row_column_option_id
        hash[question_id] = { 'name' => followup.records[0]['name'], 'id' => followup.followup_field_id }
      end
    end
  end

  def merge_questionnaire_response_items(items)
    merged_array = items.each_with_object({}) do |element, memo|
      link_id = element['linkId']
      answer = element['answer']

      if memo[link_id]
        memo[link_id]['answer'].concat(answer)
      else
        memo[link_id] = { 'linkId' => link_id, 'answer' => answer.dup }
      end
    end.values
  end

  def generate_linkid(question_row_column)
    question_row = question_row_column.question_row
    question = question_row.question

    "#{question.pos}-#{question.id}-#{question_row.id}-#{question_row_column.id}"
  end

  def build_linkid_hash(extractions_extraction_forms_projects_section)
    records = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField
              .joins(:extractions_extraction_forms_projects_section)
              .joins(question_row_column_field: { question_row_column: { question_row: :question } })
              .where(extractions_extraction_forms_projects_section:)
              .select(
                'eefps_qrcfs.id as eefpsqrcf_id',
                'questions.pos as question_pos',
                'questions.id as question_id',
                'question_rows.id as question_row_id',
                'question_row_columns.id as question_row_column_id'
              )

    records.each_with_object({}) do |record, hash|
      linkid = "#{record.question_pos}-#{record.question_id}-#{record.question_row_id}-#{record.question_row_column_id}"
      hash[record.eefpsqrcf_id] = linkid
    end
  end
end
