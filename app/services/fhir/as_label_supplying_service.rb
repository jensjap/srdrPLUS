class AsLabelSupplyingService
  BASE_URL = 'https://srdrplus.ahrq.gov/api/v3/citations/'

  def find_by_project_id(project_id)
    project = load_project_with_associations(project_id)
    artifact_assessments = []

    project.citations_projects.each do |citation|
      artifact_assessments.concat(process_abstract_screening_results(citation))
      artifact_assessments.concat(process_screening_qualifications(citation))
    end

    artifact_assessments
  end

  private

  def load_project_with_associations(project_id)
    Project.includes(
      citations_projects: [
        {
          abstract_screening_results: %i[reasons tags user]
        },
        screening_qualifications: :user,
      ],
    ).find(project_id)
  end

  def process_abstract_screening_results(citation)
    citation.abstract_screening_results.each_with_object([]) do |asr, assessments|
      next if asr.label.blank?

      user_ref = asr.user.present? ? '#practitioner_asr' : nil
      artifact_assessment = build_artifact_assessment('14', asr.id, 'AbstractScreeningResult', citation.id, asr.user)

      add_content(artifact_assessment, 'rating', 'human label', asr.label, user_ref, asr.privileged)
      add_reasons_and_tags(artifact_assessment, asr.reasons, asr.tags, user_ref)

      assessments << artifact_assessment
    end
  end

  def process_screening_qualifications(citation)
    citation.screening_qualifications.each_with_object([]) do |sq, assessments|
      user_ref = sq.user.present? ? '#practitioner_sq' : nil
      artifact_assessment = build_artifact_assessment('15', sq.id, 'ScreeningQualification', citation.id, sq.user)

      add_qualification_content(artifact_assessment, sq.qualification_type, user_ref)

      assessments << artifact_assessment
    end
  end

  def build_artifact_assessment(id_prefix, srdrplus_id, srdrplus_type, citation_id, user)
    artifact_assessment = FhirResourceService.get_artifact_assessment(
      id_prefix: id_prefix,
      srdrplus_id: srdrplus_id,
      srdrplus_type: srdrplus_type,
      artifact_uri: "#{BASE_URL}#{citation_id}",
    )

    if user.present?
      artifact_assessment['contained'] = FhirResourceService.build_contained_practitioner(id: "practitioner_#{srdrplus_type.downcase}", email: user.email)
    end

    artifact_assessment
  end

  def add_content(artifact_assessment, information_type, content_type, label, user_ref, privileged)
    content_type = privileged ? "#{content_type} (privileged)" : content_type
    artifact_assessment['content'] << FhirResourceService.build_artifact_assessment_content(
      informationType: information_type,
      type: content_type,
      quantity: label.to_f,
      user_ref: user_ref
    )
  end

  def add_reasons_and_tags(artifact_assessment, reasons, tags, user_ref)
    reasons.each do |reason|
      artifact_assessment['content'] << FhirResourceService.build_artifact_assessment_content(
        informationType: 'comment',
        type: 'label reason',
        classifier: reason.name,
        user_ref: user_ref
      )
    end

    tags.each do |tag|
      artifact_assessment['content'] << FhirResourceService.build_artifact_assessment_content(
        informationType: 'classifier',
        type: 'label tag',
        classifier: tag.name,
        user_ref: user_ref
      )
    end
  end

  def add_qualification_content(artifact_assessment, qualification_type, user_ref)
    rating_value = case qualification_type
                   when 'as-accepted' then 1.0
                   when 'as-rejected' then -1.0
                   else return
                   end

    artifact_assessment['content'] << FhirResourceService.build_artifact_assessment_content(
      informationType: 'rating',
      type: 'human label (screening qualification)',
      quantity: rating_value,
      user_ref: user_ref
    )
  end
end
