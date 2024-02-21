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
    key_questions = key_questions.map { |key_question| create_fhir_obj(key_question) }
    bundle = FhirResourceService.get_bundle(objs=key_questions, type='collection', link_info=link_info)

    return 'Error in validation' unless FhirResourceService.validate_resource(bundle)
    bundle.to_json
  end

  def find_by_key_question_id(key_question_id)
    key_question = KeyQuestionsProject.find(key_question_id)
    key_question_in_fhir = create_fhir_obj(key_question)

    return 'Error in validation' unless FhirResourceService.validate_resource(key_question_in_fhir)

    key_question_in_fhir.to_json
  end

  private

  def create_fhir_obj(raw)
    title = raw.kq_name || ''

    key_question = FhirResourceService.get_evidence_variable(
      title = title,
      id_prefix = '2',
      srdrplus_id = raw.id.to_s,
      srdrplus_type = 'KeyQuestion',
      status = 'active'
    )

    key_question
  end
end
