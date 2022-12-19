class ExtractionFormsProjectsSectionSupplyingService

  def find_by_extraction_forms_project_id(id)
    extraction_forms_projects_sections = ExtractionFormsProject.find(id).extraction_forms_projects_sections
    create_bundle(objs = extraction_forms_projects_sections, type = 'collection')
  end

  def find_by_extraction_forms_projects_section_id(id)
    extraction_forms_projects_section = ExtractionFormsProjectsSection.find(id)
    extraction_forms_projects_section_in_fhir = create_fhir_obj(extraction_forms_projects_section)
    return extraction_forms_projects_section_in_fhir.validate unless extraction_forms_projects_section_in_fhir.valid?

    extraction_forms_projects_section_in_fhir
  end

  private

  def create_bundle(objs, type)
    bundle = {
      'type' => type,
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
        'item' => []
      }
      for question in raw.questions do
        question_item = {
          'linkId' => question.id.to_s,
          'text' => 'position:' + question.position.to_s,
          'type' => 'group',
          'item' => []
        }
        for row in question.question_rows do
          row_item = {
            'linkId' => question.id.to_s + '-' + row.id.to_s,
            'text' => row.name,
            'type' => 'group',
            'item' => []
          }
          for row_column in row.question_row_columns do
            item = {
              'linkId' => question.id.to_s + '-' + row.id.to_s + '-' + row_column.id.to_s,
              'text' => row_column.name
            }

            if row_column.question_row_column_type.id == 1
              item['text'] = 'string, between ' + row_column.question_row_columns_question_row_column_options[1]['name'] + ' to ' + row_column.question_row_columns_question_row_column_options[2]['name'] + ' character'
              item['type'] = 'text'
              item['maxLength'] = row_column.question_row_columns_question_row_column_options[2]['name'].to_i
            elsif row_column.question_row_column_type.id == 2
              item['text'] = 'integer, between ' + row_column.question_row_columns_question_row_column_options[4]['name'] + ' to ' + row_column.question_row_columns_question_row_column_options[5]['name']
              item['type'] = 'integer'
            elsif row_column.question_row_column_type.id == 5
              item['text'] = 'checkbox'
              item['type'] = 'text'
              item['repeats'] = true
              item['answerConstraint'] = 'optionsOnly'
              item['answerOption'] = []
              for candidate in row_column.question_row_columns_question_row_column_options do
                if candidate['question_row_column_option_id'] == 1
                  item['answerOption'].append({
                    'valueString' => candidate['name']
                  })
                end
              end
            elsif row_column.question_row_column_type.id == 6
              item['text'] = 'dropdown'
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOnly'
              item['answerOption'] = []
              for candidate in row_column.question_row_columns_question_row_column_options do
                if candidate['question_row_column_option_id'] == 1
                  item['answerOption'].append({
                    'valueString' => candidate['name']
                  })
                end
              end
            elsif row_column.question_row_column_type.id == 7
              item['text'] = 'radio'
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOnly'
              item['answerOption'] = []
              for candidate in row_column.question_row_columns_question_row_column_options do
                if candidate['question_row_column_option_id'] == 1
                  item['answerOption'].append({
                    'valueString' => candidate['name']
                  })
                end
              end
            elsif row_column.question_row_column_type.id == 8
              item['text'] = 'select one with write-in option'
              item['type'] = 'text'
              item['repeats'] = false
              item['answerConstraint'] = 'optionsOrString'
              item['answerOption'] = []
              for candidate in row_column.question_row_columns_question_row_column_options do
                if candidate['question_row_column_option_id'] == 1
                  item['answerOption'].append({
                    'valueString' => candidate['name']
                  })
                end
              end
            elsif row_column.question_row_column_type.id == 9
              item['text'] = 'select multiple with write-in option'
              item['type'] = 'text'
              item['repeats'] = true
              item['answerConstraint'] = 'optionsOrString'
              item['answerOption'] = []
              for candidate in row_column.question_row_columns_question_row_column_options do
                if candidate['question_row_column_option_id'] == 1
                  item['answerOption'].append({
                    'valueString' => candidate['name']
                  })
                end
              end
            end

            row_item['item'].append(item)
          end
          question_item['item'].append(row_item)
        end
        extraction_forms_projects_sections['item'].append(question_item)
      end
      return FHIR::Questionnaire.new(extraction_forms_projects_sections)
    elsif raw.extraction_forms_projects_section_type_id == 4
      extraction_forms_projects_sections = {
        'status' => 'draft',
        'id' => '3' + '-' + raw.id.to_s,
        'title' => raw.section_label,
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
