class ExtractionFormsProjectsSectionSupplyingService

  def find_by_extraction_forms_project_id(id)
    efpss = ExtractionFormsProject.find(id).extraction_forms_projects_sections
    link_info = [
      {
        'relation' => 'tag',
        'url' => 'api/v3/extraction_forms_projects/' + id.to_s + '/extraction_forms_projects_sections'
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/extraction_form.txt'
      }
    ]
    create_bundle(objs=efpss, type='collection', link_info=link_info)
  end

  def find_by_extraction_forms_projects_section_id(id)
    efps = ExtractionFormsProjectsSection.find(id)
    efps_in_fhir = create_fhir_obj(efps)
    return efps_in_fhir if efps_in_fhir.blank?
    return efps_in_fhir.validate unless efps_in_fhir.valid?

    efps_in_fhir
  end

  private

  def create_bundle(objs, type, link_info)
    bundle = {
      'type' => type,
      'link' => link_info,
      'entry' => []
    }

    for obj in objs do
      fhir_obj = create_fhir_obj(obj)
      bundle['entry'].append({ 'resource' => fhir_obj }) if fhir_obj and fhir_obj.valid?
    end

    FHIR::Bundle.new(bundle)
  end

  def create_fhir_obj(raw)
    if raw.extraction_forms_projects_section_type_id == 2
      efps = {
        'status' => 'active',
        'id' => '3' + '-' + raw.id.to_s,
        'title' => raw.section_label,
        'identifier' => [{
          'type' => {
            'text' => 'SRDR+ Object Identifier'
          },
          'system' => 'https://srdrplus.ahrq.gov/',
          'value' => 'ExtractionFormsProjectsSection/' + raw.id.to_s
        }],
        'item' => []
      }
      for question in raw.questions do
        question_linkid = question.pos.to_s + '-' + question.id.to_s
        question_item = {
          'linkId' => question_linkid,
          'text' => question.name,
          'type' => 'group',
          'definition' => 'doc/fhir/questionnaire_group_question.txt',
          'item' => []
        }

        for row in question.question_rows do
          question_row_linkid = question_linkid + '-' + row.id.to_s
          row_item = {
            'linkId' => question_row_linkid,
            'text' => row.name,
            'type' => 'group',
            'definition' => 'doc/fhir/questionnaire_group_row.txt',
            'item' => []
          }
          for row_column in row.question_row_columns do
            options = row_column.question_row_columns_question_row_column_options
            question_row_column_linkid = question_row_linkid + '-' + row_column.id.to_s
            item = {
              'linkId' => question_row_column_linkid,
              'text' => row_column.name
            }

            if row_column.question_row_column_type.id == 1
              item['type'] = 'text'
              item['maxLength'] = options[2]['name'].to_i
              item['extension'] = [{
                'url' => 'http://hl7.org/fhir/StructureDefinition/minLength',
                'valueInteger' => options[1]['name'].to_i
              }]
            elsif row_column.question_row_column_type.id == 2
              item['extension'] = [
                {
                  'url' => 'http://hl7.org/fhir/StructureDefinition/minValue',
                  'valueDecimal' => options[4]['name']
                },
                {
                  'url' => 'http://hl7.org/fhir/StructureDefinition/maxValue',
                  'valueDecimal' => options[5]['name']
                }
              ]
              item['type'] = 'decimal'
            elsif row_column.question_row_column_type.id == 5
              item['type'] = 'text'
              item['repeats'] = true
              item['answerConstraint'] = 'optionsOnly'

              if not options.nil?
                item = add_answer_options_and_followups_to_item(
                  item = item,
                  options = options,
                  linkid = question_row_column_linkid
                )
              end
            elsif row_column.question_row_column_type.id == 6
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOnly'

              if not options.nil?
                item = add_answer_options_and_followups_to_item(
                  item = item,
                  options = options,
                  linkid = question_row_column_linkid
                )
              end
            elsif row_column.question_row_column_type.id == 7
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOnly'

              if not options.nil?
                item = add_answer_options_and_followups_to_item(
                  item = item,
                  options = options,
                  linkid = question_row_column_linkid
                )
              end
            elsif row_column.question_row_column_type.id == 8
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOrString'

              if not options.nil?
                item = add_answer_options_and_followups_to_item(
                  item = item,
                  options = options,
                  linkid = question_row_column_linkid
                )
              end
            elsif row_column.question_row_column_type.id == 9
              item['type'] = 'text'
              item['repeats'] = true
              item['answerConstraint'] = 'optionsOrString'

              if not options.nil?
                item = add_answer_options_and_followups_to_item(
                  item = item,
                  options = options,
                  linkid = question_row_column_linkid
                )
              end
            end
            row_item['item'].append(item)
          end
          question_item['item'].append(row_item)
        end

        if not question.dependencies.empty?
          question_item['enableWhen'] = []
          question_item['enableBehavior'] = 'any'
          dependencies = question.dependencies
          for dependency in dependencies do
            id = dependency.prerequisitable_id
            if dependency.prerequisitable_type == 'QuestionRowColumnsQuestionRowColumnOption'
              option = QuestionRowColumnsQuestionRowColumnOption.find(id)
              row_column_id = option.question_row_column_id
              row_column = QuestionRowColumn.find(row_column_id)
              row_id = row_column.question_row_id
              question_id = QuestionRow.find(row_id).question_id
              link_id = question_id.to_s + '-' + row_id.to_s + '-' + row_column_id.to_s
              enable_condition = {
                'question' => link_id,
                'operator' => '=',
                'answerString' => option.name
              }
              question_item['enableWhen'].append(enable_condition)
            elsif dependency.prerequisitable_type == 'QuestionRowColumn'
              row_column_id = id
              row_column = QuestionRowColumn.find(row_column_id)
              row_id = row_column.question_row_id
              question_id = QuestionRow.find(row_id).question_id
              link_id = question_id.to_s + '-' + row_id.to_s + '-' + row_column_id.to_s
              enable_condition = {
                'question' => link_id,
                'operator' => 'exists',
                'answerBoolean' => true
              }
              question_item['enableWhen'].append(enable_condition)
            end
          end
        end
        efps['item'].append(question_item)
      end

      return FHIR::Questionnaire.new(efps)
    end
  end

  def add_followup_to_item(
    item,
    linkid,
    followup_field_id,
    enable_answer
  )
    old_followup_item = item['item']
    followup_item = {
      'linkId' => linkid + '-' + followup_field_id,
      'type' => 'text',
      'answerOption' => 'valueString',
      'enableWhen' => {
        'question' => linkid,
        'operator' => '=',
        'answerString' => enable_answer
      }
    }
    if old_followup_item
      item['item'].append(followup_item)
    else
      item['item'] = [followup_item]
    end
    return item
  end

  def add_answer_options_and_followups_to_item(
    item,
    options,
    linkid
  )
    item['answerOption'] = []
    for option in options do
      if option['question_row_column_option_id'] == 1
        if not option['name'].empty?
          item['answerOption'].append({
            'valueString' => option['name']
          })
          if not option.followup_field.nil?
            item = add_followup_to_item(
              item = item,
              linkid = linkid,
              followup_field_id = option.followup_field.id.to_s,
              enable_answer = option['name']
            )
          end
        end
      end
    end
    return item
  end

end
