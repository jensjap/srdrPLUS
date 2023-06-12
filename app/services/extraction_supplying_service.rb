class ExtractionSupplyingService

  def find_by_project_id(id)
    extractions = Project.find(id).extractions
    extraction_bundles = []
    for extraction in extractions do
      extraction_bundles.append(find_by_extraction_id(extraction.id))
    end

    link_info = [
      {
        'relation' => 'tag',
        'url' => 'api/v3/projects/' + id.to_s + '/extractions'
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/extraction.txt'
      }
    ]
    create_bundle(objs=extraction_bundles, type='collection', link_info=link_info)
  end

  def find_by_extraction_id(id)
    extraction = Extraction.find(id)
    fhir_extraction_sections = []

    efpss = extraction.extraction_forms_projects_sections.first.extraction_forms_project.extraction_forms_projects_sections
    extraction_sections = []
    for efps in efpss do
      eefpss = efps.extractions_extraction_forms_projects_sections
      for eefps in eefpss do
        if eefps.extraction_id == id.to_i
          extraction_sections.append(eefps)
        end
      end
    end
    for extraction_section in extraction_sections do
      fhir_extraction_sections.append(create_fhir_obj(extraction_section))
    end

    link_info = [
      {
        'relation' => 'tag',
        'url' => 'api/v3/extractions/' + id.to_s
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/extraction.txt'
      }
    ]
    create_bundle(objs=fhir_extraction_sections, type='collection', link_info=link_info)
  end

  private

  def create_bundle(fhir_objs, type, link_info=nil)
    bundle = {
      'type' => type,
      'link' => link_info,
      'entry' => []
    }

    for fhir_obj in fhir_objs do
      bundle['entry'].append({ 'resource' => fhir_obj }) if fhir_obj and fhir_obj.valid?
    end

    FHIR::Bundle.new(bundle)
  end

  def create_fhir_obj(raw)
    form = ExtractionFormsProjectsSection.find(raw.extraction_forms_projects_section_id)

    if form.extraction_forms_projects_section_type_id == 1
      evidence_variables = []
      if raw.status['name'] == 'Draft'
        status = 'draft'
      elsif raw.status['name'] == 'Completed'
        status = 'active'
      end

      for row in raw.extractions_extraction_forms_projects_sections_type1s do
        info = Type1.find(row['type1_id'])
        evidence_variable = {
          'status' => status,
          'id' => '6' + '-' + row['type1_id'].to_s,
          'title' => info['name'],
          'description' => info['description'],
          'identifier' => [{
            'type' => {
              'text' => 'SRDR+ Object Identifier'
            },
            'system' => 'https://srdrplus.ahrq.gov/',
            'value' => 'Type1/' + row['type1_id'].to_s
          }],
        }

        evidence_variables.append(FHIR::EvidenceVariable.new(evidence_variable))
      end

      if evidence_variables.empty?
        return
      end

      link_info = [{
        'relation' => 'service-doc',
        'url' => 'doc/fhir/evidence_variable.txt'
      }]
      return create_bundle(objs=evidence_variables, type='collection', link_info=link_info)
    elsif form.extraction_forms_projects_section_type_id == 2
      if raw.status['name'] == 'Draft'
        status = 'in-progress'
      elsif raw.status['name'] == 'Completed'
        status = 'completed'
      end

      questions = ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_projects_section_id(form.id)
      return if questions.blank?

      eefpss = []
      eefpsqrcf_grouped_by_type1 = raw.extractions_extraction_forms_projects_sections_question_row_column_fields.group_by { |item| item["extractions_extraction_forms_projects_sections_type1_id"] }
      eefpsqrcf_grouped_by_type1.each do |eefps_type1_id, eefpsqrcfs|

        eefps = {
          'status' => status,
          'id' => '4' + '-' + raw.id.to_s,
          'text' => form.section_label,
          'identifier' => [{
            'type' => {
              'text' => 'SRDR+ Object Identifier'
            },
            'system' => 'https://srdrplus.ahrq.gov/',
            'value' => 'ExtractionsExtractionFormsProjectsSection/' + raw.id.to_s
          }],
          'contained' => questions,
          'questionnaire' => '#' + questions.id,
          'subject' => {},
          'item' => []
        }

        if eefps_type1_id.blank?
          next
        else
          type1 = ExtractionsExtractionFormsProjectsSectionsType1.find(eefps_type1_id).type1
          type1_display = type1.name + ' (' + type1.description + ')'
          eefps['subject'] = {
            'reference' => 'Type1/' + type1.id.to_s,
            'type' => 'EvidenceVariable',
            'display' => type1_display
          }

          restriction_symbol = ''
          for eefpsqrcf in eefpsqrcfs do
            question_row_column_field = eefpsqrcf.question_row_column_field
            question_row_column_id = question_row_column_field.question_row_column_id
            question_row_column = QuestionRowColumn.find(question_row_column_id)
            ans_form = question_row_column.question_row_columns_question_row_column_options
            question_row_id = question_row_column.question_row_id
            question_row = QuestionRow.find(question_row_id)
            question_id = question_row.question_id
            question = Question.find(question_id)
            type = question_row_column.question_row_column_type.id
            value = eefpsqrcf.records[0]['name']
            if value.is_a?(String) && value.empty?
              value = nil
            end

            if not eefpsqrcf.extractions_extraction_forms_projects_sections_type1&.nil?
              type1 = eefpsqrcf.extractions_extraction_forms_projects_sections_type1&.type1
            else
              type1 = nil
            end

            if not eefpsqrcf.extractions_extraction_forms_projects_sections_type1&.type1_type.nil?
              type1_type = eefpsqrcf.extractions_extraction_forms_projects_sections_type1&.type1_type
            else
              type1_type = nil
            end

            if value.nil?
              if type != 9
                next
              end
            else
              if type != 9
                item = {
                  'linkId' => question.pos.to_s + '-' + question_id.to_s + '-' + question_row_id.to_s + '-' + question_row_column_id.to_s
                }
              end
            end

            followups = {}
            for followup in raw.extractions_extraction_forms_projects_sections_followup_fields do
              if not followup.records[0]['name'].blank?
                followups = followups.merge({
                  FollowupField.find(followup.followup_field_id).question_row_columns_question_row_column_option_id => {
                    'name' => followup.records[0]['name'],
                    'id' => followup.followup_field_id
                  }
                })
              end
            end

            if type == 1
              item['answer'] = {
                'valueString' => value
              }
              eefps['item'].append(item)
            elsif type == 2
              if /-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?/.match(value)
                item['answer'] = {
                  'valueDecimal' => value
                }
                eefps['item'].append(item)
                unless restriction_symbol.empty?
                  symbol_item = {
                    'linkId' => question.pos.to_s + '-' + question_id.to_s + '-' + question_row_id.to_s + '-' + question_row_column_id.to_s,
                    'answer' => {
                      'valueString' => restriction_symbol
                    }
                  }
                  eefps['item'].append(symbol_item)
                end
                restriction_symbol = ''
              else
                restriction_symbol = value
              end
            elsif type == 5
              matches = value.scan(/\D*(\d+)\D*/)
              for match in matches do
                checkbox_id = match[0].to_i
                name = ans_form.find(checkbox_id)['name']
                item['answer'] = {
                  'valueString' => name
                }

                if followups.has_key?(checkbox_id)
                  followup_item = {}
                  followup_item['linkId'] = item['linkId'] + '-' + followups[checkbox_id]['id'].to_s
                  followup_item['answer'] = {
                    'valueString' => followups[checkbox_id]['name']
                  }
                  item['item'] = followup_item
                else
                  item['item'] = []
                end

                eefps['item'].append(item.dup)
              end
            elsif type == 6
              name = ans_form.find(value)['name']
              item['answer'] = {
                'valueString' => name
              }
              eefps['item'].append(item)
            elsif type == 7
              name = ans_form.find(value)['name']
              item['answer'] = {
                'valueString' => name
              }
              eefps['item'].append(item)
              if followups.has_key?(value.to_i)
                followup_item = {}
                followup_item['linkId'] = item['linkId'] + '-' + followups[value.to_i]['id'].to_s
                followup_item['answer'] = {
                  'valueString' => followups[value.to_i]['name']
                }
                eefps['item'].append(followup_item)
              end
            elsif type == 8
              name = ans_form.find(value)['name']
              item['answer'] = {
                'valueString' => name
              }
              eefps['item'].append(item)
            elsif type == 9
              for dicts in eefpsqrcf.extractions_extraction_forms_projects_sections_question_row_column_fields_question_row_columns_question_row_column_options do
                item = {
                  'linkId' => question.pos.to_s + '-' + question_id.to_s + '-' + question_row_id.to_s + '-' + question_row_column_id.to_s
                }
                value = dicts.question_row_columns_question_row_column_option_id
                name = ans_form.find(value)['name']
                item['answer'] = {
                  'valueString' => name
                }
                eefps['item'].append(item)
              end
              item = {}
            end
          end

          if eefps['item'].empty?
            next
          end

          eefpss.append(FHIR::QuestionnaireResponse.new(eefps))
        end
      end

      if eefpss.empty?
        return
      end

      link_info = [
        {
          'relation' => 'service-doc',
          'url' => 'doc/fhir/questionnaire_response_group_by_type1.txt'
        }
      ]
      return create_bundle(objs=eefpss, type='collection', link_info=link_info)

    elsif form.extraction_forms_projects_section_type_id == 3
      extraction = Extraction.find(raw.extraction_id)
      project = Project.find(extraction.project_id)
      efp_type_id = extraction.extraction_forms_projects_sections.first.extraction_forms_project.extraction_forms_project_type_id
      if efp_type_id == 1
        outcomes = ExtractionsExtractionFormsProjectsSectionsType1
          .by_section_name_and_extraction_id_and_extraction_forms_project_id(
            'Outcomes',
            raw.extraction_id,
            project.extraction_forms_projects.first.id
          )
        evidences = []

        for outcome in outcomes do
          if outcome.status['name'] == 'Draft'
            outcome_status = 'draft'
          elsif outcome.status['name'] == 'Completed'
            outcome_status = 'active'
          end

          outcome_name = Type1.find(outcome.type1_id)['name']
          populations = outcome.extractions_extraction_forms_projects_sections_type1_rows

          for population in populations do
            population_name = PopulationName.find(population.population_name_id)['name']
            result_statistic_sections = population.result_statistic_sections

            for sec_num in [0, 1, 2, 3] do
              if sec_num == 0
                for result_statistic_sections_measure in result_statistic_sections[sec_num].result_statistic_sections_measures do
                  measure_name = Measure.find(result_statistic_sections_measure.measure_id)['name']
                  for tps_arms_rssm in result_statistic_sections_measure.tps_arms_rssms do
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

                    evidences.append(evidence)
                  end
                end
              elsif sec_num == 1
                for result_statistic_sections_measure in result_statistic_sections[sec_num].result_statistic_sections_measures do
                  measure_name = Measure.find(result_statistic_sections_measure.measure_id)['name']
                  for tps_comparisons_rssm in result_statistic_sections_measure.tps_comparisons_rssms do
                    record, record_id = get_record_and_id(tps_comparisons_rssm)
                    next if record.nil?

                    time_point_name = get_time_point_name(tps_comparisons_rssm.timepoint_id)
                    next if time_point_name.nil?

                    comparison = Comparison.find_by(id: tps_comparisons_rssm.comparison_id)
                    next if comparison.blank?

                    arm_names = []
                    for comparate_group in comparison.comparate_groups do
                      comparable_elements = comparate_group.comparable_elements
                      arm_name_in_same_comparate_group = []
                      for comparable_element in comparable_elements do
                        arm_name = get_arm_name(comparable_element.comparable_id)
                        arm_name_in_same_comparate_group.append(arm_name)
                      end
                      arm_names.append(arm_name_in_same_comparate_group)
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

                    evidences.append(evidence)
                  end
                end
              elsif sec_num == 2
                for result_statistic_sections_measure in result_statistic_sections[sec_num].result_statistic_sections_measures do
                  measure_name = Measure.find(result_statistic_sections_measure.measure_id)['name']
                  for comparisons_arms_rssm in result_statistic_sections_measure.comparisons_arms_rssms do
                    record, record_id = get_record_and_id(comparisons_arms_rssm)
                    next if record.nil?

                    comparison = Comparison.find_by(id: comparisons_arms_rssm.comparison_id)
                    next if comparison.blank?

                    time_point_names = []
                    for comparate_group in comparison.comparate_groups do
                      comparable_elements = comparate_group.comparable_elements
                      time_point_name = get_time_point_name(comparable_elements[0].comparable_id)
                      time_point_names.append(time_point_name)
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

                    evidences.append(evidence)
                  end
                end
              elsif sec_num == 3
                for result_statistic_sections_measure in result_statistic_sections[sec_num].result_statistic_sections_measures do
                  measure_name = Measure.find(result_statistic_sections_measure.measure_id)['name']
                  for wacs_bacs_rssm in result_statistic_sections_measure.wacs_bacs_rssms do
                    record, record_id = get_record_and_id(wacs_bacs_rssm)
                    next if record.nil?

                    comparison_arm = Comparison.find_by(id: wacs_bacs_rssm.bac_id)
                    next if comparison_arm.blank?

                    arm_names = []
                    for comparate_group in comparison_arm.comparate_groups do
                      comparable_elements = comparate_group.comparable_elements
                      arm_name_in_same_comparate_group = []
                      for comparable_element in comparable_elements do
                        arm_name = get_arm_name(comparable_element.comparable_id)
                        arm_name_in_same_comparate_group.append(arm_name)
                      end
                      arm_names.append(arm_name_in_same_comparate_group)
                    end

                    comparison_time_point = Comparison.find_by(id: wacs_bacs_rssm.wac_id)
                    next if comparison_time_point.blank?

                    time_point_names = []
                    for comparate_group in comparison_time_point.comparate_groups do
                      comparable_elements = comparate_group.comparable_elements
                      time_point_name = get_time_point_name(comparable_elements[0].comparable_id)
                      time_point_names.append(time_point_name)
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

                    evidences.append(evidence)
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
          merged_evidences = merged_evidences.map do |element|
            FHIR::Evidence.new(element)
          end
          link_info_evidence = [{
            'relation' => 'service-doc',
            'url' => 'doc/fhir/extraction.txt'
          }]
          return create_bundle(fhir_objs=merged_evidences, type='collection', link_info=link_info_evidence)
        end

      else
        outcomes = ExtractionsExtractionFormsProjectsSectionsType1
          .by_section_name_and_extraction_id_and_extraction_forms_project_id(
            'Diagnoses',
            raw.extraction_id,
            project.extraction_forms_projects.first.id
          )
        evidences = []

        for outcome in outcomes do
          if outcome.status['name'] == 'Draft'
            outcome_status = 'draft'
          elsif outcome.status['name'] == 'Completed'
            outcome_status = 'active'
          end

          outcome_name = Type1.find(outcome.type1_id)['name']
          populations = outcome.extractions_extraction_forms_projects_sections_type1_rows

          for population in populations do
            population_name = PopulationName.find(population.population_name_id)['name']
            result_statistic_sections = population.result_statistic_sections

            for sec_num in [4, 5, 6, 7] do
              for result_statistic_sections_measure in result_statistic_sections[sec_num].result_statistic_sections_measures do
                measure_name = Measure.find(result_statistic_sections_measure.measure_id)['name']
                for tps_comparisons_rssm in result_statistic_sections_measure.tps_comparisons_rssms do
                  record, record_id = get_record_and_id(tps_comparisons_rssm)
                  next if record.nil?

                  time_point_name = get_time_point_name(tps_comparisons_rssm.timepoint_id)
                  next if time_point_name.nil?

                  comparison = Comparison.find_by(id: tps_comparisons_rssm.comparison_id)
                  if comparison.blank?
                    next
                  end
                  arm_names = []
                  for comparate_group in comparison.comparate_groups do
                    comparable_elements = comparate_group.comparable_elements
                    arm_name_in_same_comparate_group = []
                    for comparable_element in comparable_elements do
                      arm_name = get_arm_name(comparable_element.comparable_id)
                      arm_name_in_same_comparate_group.append(arm_name)
                    end
                    arm_names.append(arm_name_in_same_comparate_group)
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

                  evidences.append(evidence)
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
          merged_evidences = merged_evidences.map do |element|
            FHIR::Evidence.new(element)
          end
          link_info_evidence = [{
            'relation' => 'service-doc',
            'url' => 'doc/fhir/extraction.txt'
          }]
          return create_bundle(fhir_objs=merged_evidences, type='collection', link_info=link_info_evidence)
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
    statistic_type_count = item["statistic"].count do |statistic|
      statistic.key?("statisticType")
    end

    if statistic_type_count > 1
      merge_targets = item["statistic"].select do |statistic|
        !statistic.key?("statisticType")
      end
      keep_targets = item["statistic"].select do |statistic|
        statistic.key?("statisticType")
      end
    else
      merge_targets = item["statistic"]
      keep_targets = []
    end

    attribute_estimate_arr = []
    merged_statistic = merge_targets.reduce({}) do |result, current|
      if current.key?("attributeEstimate")
        attribute_estimate_arr += current["attributeEstimate"]
        current = current.reject { |key, _| key == "attributeEstimate" }
      end
      result.merge(current) { |key, oldval, newval| oldval + newval }
    end

    unless attribute_estimate_arr.empty?
      merged_statistic["attributeEstimate"] = attribute_estimate_arr
    end

    item["statistic"] = [merged_statistic] + keep_targets
    item
  end
end

  def build_variable_definition(description, code)
    {
      'description' => description,
      'variableRole' => {
        'coding' => [{
          'system' => 'http://terminology.hl7.org/CodeSystem/variable-role',
          'code' => code
        }]
      }
    }
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
    evidence = {
      'id' => "5-#{record_id}",
      'status' => outcome_status,
      'identifier' => [{
        'type' => {
          'text' => 'SRDR+ Object Identifier'
        },
        'system' => 'https://srdrplus.ahrq.gov/',
        'value' => "Record/#{record_id}"
      }],
      'variableDefinition' => [
        build_variable_definition(population_name, 'population')
      ],
      'statistic' => [{}]
    }

    case measure_name
    when 'Total (N analyzed)'
      evidence['statistic'][0]['sampleSize'] = {'knownDataCount' => {'value' => record}}
    when 'Events'
      evidence['statistic'][0]['numberOfEvents'] = record
    when '95% CI low (OR)'
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
            'value' => record
          }
        }
      }]
    when '95% CI high (OR)'
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
            'value' => record
          }
        }
      }]
    when 'p value'
      evidence['statistic'][0]['attributeEstimate'] = [{
        'type' => {
          'coding' => [{
            'system' => 'http://terminology.hl7.org/CodeSystem/attribute-estimate-type',
            'code' => 'C44185',
            'display' => 'P-value'
          }]
        },
        'quantity' => {
          'value' => record
        }
      }]
    else
      evidence['statistic'][0]['quantity'] = {'value' => record}
      evidence['statistic'][0]['description'] = measure_name
    end

    arm_name_variable_roles = ['exposure', 'referenceExposure']
    if arm_name_groups.length == 1 and !arm_name_groups[0].is_a?(Array)
      evidence['variableDefinition'].append(build_variable_definition(arm_name_groups[0], arm_name_variable_roles[0]))
    else
      arm_name_groups.each_with_index do |arm_name_group, index|
        arm_name_group = [arm_name_group] unless arm_name_group.respond_to?(:each)
        arm_name_group.each do |arm_name|
          evidence['variableDefinition'].append(build_variable_definition(arm_name, arm_name_variable_roles[index]))
        end
      end
    end

    time_point_string = time_point_names.join(' - ')
    evidence['variableDefinition'].append(build_variable_definition("#{outcome_name}, #{time_point_string}", 'measuredVariable'))

    statistic_type_mapping = {
      'Proportion' => ['C44256', 'Proportion'],
      'Incidence Rate (per 1000)' => ['C16726', 'Incidence'],
      'Incidence rate (per 10,000)' => ['C16726', 'Incidence'],
      'Incidence rate (per 100,000)' => ['C16726', 'Incidence'],
      'Odds Ratio (OR)' => ['C16932', 'Odds Ratio'],
      'Odds Ratio, Adjusted (adjOR)' => ['C16932', 'Odds Ratio'],
      'Incidence Rate Ratio (IRR)' => ['rate-ratio', 'Incidence Rate Ratio'],
      'Incidence Rate Ratio, Adjusted (adjIRR)' => ['rate-ratio', 'Incidence Rate Ratio'],
      'Hazard Ratio (HR)' => ['C93150', 'Hazard Ratio'],
      'Hazard Ratio, Adjusted (adjHR)' => ['C93150', 'Hazard Ratio'],
      'Risk Difference (RD)' => ['0000424', 'Risk Difference'],
      'Risk Difference, Adjusted (adjRD)' => ['0000424', 'Risk Difference']
    }

    exception_measure_names = ['Total (N analyzed)', 'Events', '95% CI low (OR)', '95% CI high (OR)', 'p value']

    if statistic_type_mapping.key?(measure_name)
      code, display = statistic_type_mapping[measure_name]
      evidence['statistic'][0]['statisticType'] = {
        'coding' => [{
          'system' => 'http://terminology.hl7.org/CodeSystem/statistic-type',
          'code' => code,
          'display' => display
        }]
      }
    elsif !exception_measure_names.include?(measure_name)
      evidence['statistic'][0]['statisticType'] = {
        'text' => measure_name
      }
    end

    evidence
  end
end
