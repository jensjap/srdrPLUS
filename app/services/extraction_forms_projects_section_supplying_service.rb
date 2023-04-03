class ExtractionFormsProjectsSectionSupplyingService

  def find_by_extraction_forms_project_id(id)
    extraction_forms_projects_sections = ExtractionFormsProject.find(id).extraction_forms_projects_sections
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
    create_bundle(objs=extraction_forms_projects_sections, type='collection', link_info=link_info)
  end

  def find_by_extraction_forms_projects_section_id(id)
    extraction_forms_projects_section = ExtractionFormsProjectsSection.find(id)
    extraction_forms_projects_section_in_fhir = create_fhir_obj(extraction_forms_projects_section)
    return extraction_forms_projects_section_in_fhir.validate unless extraction_forms_projects_section_in_fhir.valid?

    extraction_forms_projects_section_in_fhir
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
    if raw.extraction_forms_projects_section_type_id == 1
      extraction_forms_projects_sections = {
        'status' => 'draft',
        'id' => '3' + '-' + raw.id.to_s,
        'title' => raw.section_label,
        'identifier' => [{
          'type' => {
            'text' => 'SRDR+ Object Identifier'
          },
          'system' => 'https://srdrplus.ahrq.gov/',
          'value' => 'ExtractionFormsProjectsSection/' + raw.id.to_s
        }],
        'characteristic' => []
      }
      for row in raw.extraction_forms_projects_sections_type1s do
        info = Type1.find(row['type1_id'])
        extraction_forms_projects_sections['characteristic'].append({
          'description' => info['description'],
          'definitionCodeableConcept' => {
            'text' => info['name']
          }
        })
      end
      return FHIR::EvidenceVariable.new(extraction_forms_projects_sections)
    elsif raw.extraction_forms_projects_section_type_id == 2
      extraction_forms_projects_sections = {
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
          'item' => []
        }

        for row in question.question_rows do
          question_row_linkid = question_linkid + '-' + row.id.to_s
          row_item = {
            'linkId' => question_row_linkid,
            'text' => row.name,
            'type' => 'group',
            'item' => []
          }
          for row_column in row.question_row_columns do
            question_row_column_linkid = question_row_linkid + '-' + row_column.id.to_s
            item = {
              'linkId' => question_row_column_linkid,
              'text' => row_column.name
            }

            if row_column.question_row_column_type.id == 1
              item['type'] = 'text'
              item['maxLength'] = row_column.question_row_columns_question_row_column_options[2]['name'].to_i
              item['extension'] = [{
                'url' => 'http://hl7.org/fhir/StructureDefinition/minLength',
                'valueInteger' => row_column.question_row_columns_question_row_column_options[1]['name'].to_i
              }]
            elsif row_column.question_row_column_type.id == 2
              item['extension'] = [
                {
                  'url' => 'http://hl7.org/fhir/StructureDefinition/minValue',
                  'valueDecimal' => row_column.question_row_columns_question_row_column_options[4]['name']
                },
                {
                  'url' => 'http://hl7.org/fhir/StructureDefinition/maxValue',
                  'valueDecimal' => row_column.question_row_columns_question_row_column_options[5]['name']
                }
              ]
              item['type'] = 'decimal'
            elsif row_column.question_row_column_type.id == 5
              item['type'] = 'text'
              item['repeats'] = true
              item['answerConstraint'] = 'optionsOnly'
              
              if not row_column.question_row_columns_question_row_column_options.nil?
                item['answerOption'] = []
                for candidate in row_column.question_row_columns_question_row_column_options do
                  if candidate['question_row_column_option_id'] == 1
                    if not candidate['name'].empty?
                      item['answerOption'].append({
                        'valueString' => candidate['name']
                      })
                      if not candidate.followup_field.nil?
                        item['item'] = {
                          'linkId' => question_row_column_linkid + '-' + candidate.followup_field.id.to_s,
                          'type' => 'text',
                          'answerOption' => 'valueString',
                          'enableWhen' => {
                            'question' => question_row_column_linkid,
                            'operator' => '=',
                            'answerString' => candidate['name']
                          }
                        }
                      end
                    end
                  end
                end
              end
            elsif row_column.question_row_column_type.id == 6
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOnly'
              
              if not row_column.question_row_columns_question_row_column_options.nil?
                item['answerOption'] = []
                for candidate in row_column.question_row_columns_question_row_column_options do
                  if candidate['question_row_column_option_id'] == 1
                    if not candidate['name'].empty?
                      item['answerOption'].append({
                        'valueString' => candidate['name']
                      })
                    end
                  end
                end
              end
            elsif row_column.question_row_column_type.id == 7
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOnly'
              
              if not row_column.question_row_columns_question_row_column_options.nil?
                item['answerOption'] = []
                for candidate in row_column.question_row_columns_question_row_column_options do
                  if candidate['question_row_column_option_id'] == 1
                    if not candidate['name'].empty?
                      item['answerOption'].append({
                        'valueString' => candidate['name']
                      })
                      if not candidate.followup_field.nil?
                        item['item'] = {
                          'linkId' => question_row_column_linkid + '-' + candidate.followup_field.id.to_s,
                          'type' => 'text',
                          'answerOption' => 'valueString',
                          'enableWhen' => {
                            'question' => question_row_column_linkid,
                            'operator' => '=',
                            'answerString' => candidate['name']
                          }
                        }
                      end
                    end
                  end
                end
              end
            elsif row_column.question_row_column_type.id == 8
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOrString'
              
              if not row_column.question_row_columns_question_row_column_options.nil?
                item['answerOption'] = []
                for candidate in row_column.question_row_columns_question_row_column_options do
                  if candidate['question_row_column_option_id'] == 1
                    if not candidate['name'].empty?
                      item['answerOption'].append({
                        'valueString' => candidate['name']
                      })
                    end
                  end
                end
              end
            elsif row_column.question_row_column_type.id == 9
              item['type'] = 'text'
              item['repeats'] = true
              item['answerConstraint'] = 'optionsOrString'
              
              if not row_column.question_row_columns_question_row_column_options.nil?
                item['answerOption'] = []
                for candidate in row_column.question_row_columns_question_row_column_options do
                  if candidate['question_row_column_option_id'] == 1
                    if not candidate['name'].empty?
                      item['answerOption'].append({
                        'valueString' => candidate['name']
                      })
                    end
                  end
                end
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
        extraction_forms_projects_sections['item'].append(question_item)
      end

      return FHIR::Questionnaire.new(extraction_forms_projects_sections)
    elsif raw.extraction_forms_projects_section_type_id == 4
      extraction_forms_projects_sections = {
        'status' => 'draft',
        'id' => '3' + '-' + raw.id.to_s,
        'title' => raw.section_label,
        'identifier' => [{
          'type' => {
            'text' => 'SRDR+ Object Identifier'
          },
          'system' => 'https://srdrplus.ahrq.gov/',
          'value' => 'ExtractionFormsProjectsSection/' + raw.id.to_s
        }],
        'characteristic' => []
      }
      for row in raw.extraction_forms_projects_sections_type1s do
        info = Type1.find(row['type1_id'])
        characteristic = {
          'description' => info['description'],
          'definitionCodeableConcept' => {
            'text' => info['name']
          }
        }

        if row['type1_type_id'] == 5
          characteristic['note'] = {'text' => 'Index Test'}
        elsif row['type1_type_id'] == 6
          characteristic['note'] = {'text' => 'Reference Test'}
        end

        extraction_forms_projects_sections['characteristic'].append(characteristic)
      end
      return FHIR::EvidenceVariable.new(extraction_forms_projects_sections)
    end
  end
end
