class ExtractionFormsProjectsSectionSupplyingService

  def find_by_extraction_forms_project_id(id)
    efp = ExtractionFormsProject.find(id)
    efpss = efp.extraction_forms_projects_sections.map { |efps| create_fhir_obj(efps) }.compact
    link_info = [
      {
        'relation' => 'tag',
        'url' => "api/v3/extraction_forms_projects/#{id}/extraction_forms_projects_sections"
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/extraction_form.txt'
      }
    ]
    full_urls = FhirResourceService.build_full_url(resources: efpss, relative_path: 'extraction_forms_projects_sections/')
    bundle = FhirResourceService.get_bundle(fhir_objs: efpss, type: 'collection', link_info: link_info, full_urls: full_urls)

    bundle
  end

  def find_by_extraction_forms_projects_section_id(id)
    efps = ExtractionFormsProjectsSection.includes(
      questions: [{
        question_rows: [{
          question_row_columns: [{
            question_row_columns_question_row_column_options: [
              :followup_field, :dependencies
            ]
          }]
        }]
      }]
    ).find(id)
    efps_in_fhir = create_fhir_obj(efps)
    return efps_in_fhir if efps_in_fhir.blank?

    efps_in_fhir
  end

  private

  def create_fhir_obj(raw)
    if raw.extraction_forms_projects_section_type_id == 2
      q_items = []

      raw.questions.each do |question|
        q_linkid = "#{question.pos}-#{question.id}"
        qr_items = []
        q_enable_when = q_enable_behavior = nil
        q_text = question.name if !question.name.blank?

        question.question_rows.each do |row|
          qr_linkid = "#{q_linkid}-#{row.id}"
          qrc_items = []
          qr_text = row.name if !row.name.blank?

          row.question_row_columns.each do |row_column|
            qrc_linkid = "#{qr_linkid}-#{row_column.id}"
            qrc_text = row_column.name if !row_column.name.blank?

            options = row_column.question_row_columns_question_row_column_options
            qrc_answer_options, followup_items = get_answer_options_and_related_followup_items(qrc_linkid, options)

            qrc_type, qrc_repeats, qrc_max_length, qrc_extension, qrc_answer_constraint = determine_qrc_properties(row_column, options)

            qrc_params = {
              linkid: qrc_linkid,
              type: qrc_type,
              text: qrc_text
            }

            qrc_params[:repeats] = qrc_repeats unless qrc_repeats.nil?
            qrc_params[:maxLength] = qrc_max_length unless qrc_max_length.nil?
            qrc_params[:extension] = qrc_extension unless qrc_extension.nil?
            qrc_params[:answer_constraint] = qrc_answer_constraint unless qrc_answer_constraint.nil?
            qrc_params[:answer_options] = qrc_answer_options unless qrc_answer_options.blank?
            qrc_params[:items] = followup_items unless followup_items.blank?

            qrc_item = FhirResourceService.build_questionnaire_item(**qrc_params)
            qrc_items << qrc_item
          end

          qr_params = {
            linkid: qr_linkid,
            type: 'group',
            text: qr_text,
            definition: 'doc/fhir/questionnaire_group_row.txt',
            items: qrc_items
          }

          qr_item = FhirResourceService.build_questionnaire_item(**qr_params)
          qr_items << qr_item
        end

        if !question.dependencies.blank?
          q_enable_when = []
          q_enable_behavior = 'any'
          dependencies = question.dependencies
          dependencies.each do |dependency|
            id = dependency.prerequisitable_id
            if dependency.prerequisitable_type == 'QuestionRowColumnsQuestionRowColumnOption'
              option = QuestionRowColumnsQuestionRowColumnOption.find(id)
              row_column_id = option.question_row_column_id
              row_column = QuestionRowColumn.find(row_column_id)
              row_id = row_column.question_row_id
              question_id = QuestionRow.find(row_id).question_id
              link_id = question_id.to_s + '-' + row_id.to_s + '-' + row_column_id.to_s
              q_enable_when << [link_id, '=', option.name]
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
              q_enable_when << [link_id, 'exists', true]
            end
          end
        end

        q_params = {
          linkid: q_linkid,
          text: q_text,
          type: 'group',
          definition: 'doc/fhir/questionnaire_group_question.txt',
          items: qr_items
        }
        q_params[:enable_when_items] = q_enable_when unless q_enable_when.nil?
        q_params[:enable_behavior] = q_enable_behavior unless q_enable_behavior.nil?

        q_item = FhirResourceService.build_questionnaire_item(**q_params)
        q_items << q_item
      end

      efps = FhirResourceService.get_questionnaire(
        title: raw.section_label,
        id_prefix: '3',
        srdrplus_id: raw.id,
        srdrplus_type: 'ExtractionFormsProjectsSection',
        status: 'active',
        items: q_items
      )

      return efps if !efps['item'].blank?
    end
  end

  def get_followup_item(linkid, followup_field_id, enable_answer)
    FhirResourceService.build_questionnaire_item(
      linkid: "#{linkid}-#{followup_field_id}",
      type: 'text',
      enable_when_items: [[linkid, '=', enable_answer]]
    )
  end

  def get_answer_options_and_related_followup_items(linkid, options)
    answer_options = []
    followup_items = []
    options.each do |option|
      if option['question_row_column_option_id'] == 1
        if !option['name'].blank?
          answer_options << option['name']
          if !option.followup_field.blank?
            followup_items << get_followup_item(linkid, option.followup_field.id.to_s, option['name'])
          end
        end
      end
    end

    return answer_options, followup_items
  end

  def determine_qrc_properties(row_column, options)
    qrc_type = qrc_repeats = qrc_max_length = qrc_extension = qrc_answer_constraint = nil

    case row_column.question_row_column_type.id
    when 1
      qrc_type = 'text'
      qrc_max_length = options[2]['name'].to_i
      qrc_extension = [{
        'url' => 'http://hl7.org/fhir/StructureDefinition/minLength',
        'valueInteger' => options[1]['name'].to_i
      }]
    when 2
      qrc_type = 'decimal'
      qrc_extension = [
        {'url' => 'http://hl7.org/fhir/StructureDefinition/minValue', 'valueDecimal' => options[4]['name'].to_i},
        {'url' => 'http://hl7.org/fhir/StructureDefinition/maxValue', 'valueDecimal' => options[5]['name'].to_i}
      ]
    when 5
      qrc_type = 'text'
      qrc_repeats = true
      qrc_answer_constraint = 'optionsOnly'
    when 6
      qrc_type = 'text'
      qrc_repeats = false
      qrc_answer_constraint = 'optionsOnly'
    when 7
      qrc_type = 'text'
      qrc_repeats = false
      qrc_answer_constraint = 'optionsOnly'
    when 8
      qrc_type = 'text'
      qrc_repeats = false
      qrc_answer_constraint = 'optionsOrString'
    when 9
      qrc_type = 'text'
      qrc_repeats = true
      qrc_answer_constraint = 'optionsOrString'
    end

    [qrc_type, qrc_repeats, qrc_max_length, qrc_extension, qrc_answer_constraint]
  end
end
