class KeyQuestionSupplyingService

  def find_by_project_id(project_id)
    key_questions = Project
                    .find(project_id)
                    .key_questions_projects
                    .all
    link_info = [
      {
        'relation' => 'tag',
        'url' => 'api/v3/projects/' + project_id.to_s + '/key_questions'
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/key_question.txt'
      }
    ]
    create_bundle(objs=key_questions, type='collection', link_info=link_info)
  end

  def find_by_key_question_id(key_question_id)
    key_question = KeyQuestionsProject.find(key_question_id)
    key_question_in_fhir = create_fhir_obj(key_question)

    return key_question_in_fhir.validate unless key_question_in_fhir.valid?

    key_question_in_fhir
  end

  private

  def create_bundle(objs, type, link_info=nil)
    bundle = {
      'type' => type,
      'link' => link_info,
      'entry' => []
    }

    for obj in objs do
      fhir_obj = create_fhir_obj(obj)
      bundle['entry'].append({ 'resource' => fhir_obj }) if fhir_obj.valid?
    end

    FHIR::Bundle.new(bundle)
  end

  def create_fhir_obj(raw)
    key_question = {
      'status' => 'active',
      'id' => '2' + '-' + raw.id.to_s,
      'identifier' => [{
        'type' => {
          'text' => 'SRDR+ Object Identifier'
        },
        'system' => 'https://srdrplus.ahrq.gov/',
        'value' => 'KeyQuestion/' + raw.id.to_s
      }]
    }

    title = raw.kq_name
    if title
      key_question['title'] = title
    end

    FHIR::EvidenceVariable.new(key_question)
  end
end
