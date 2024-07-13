class AllResourceSupplyingService

  def transaction_find_by_project_id(id)
    project = Project
              .includes(:mesh_descriptors)
              .includes(:citations)
              .includes(:key_questions_projects)
              .includes(:extractions)
              .includes(:sd_meta_data)
              .includes(extraction_forms_projects: :extraction_forms_projects_sections)
              .includes(
                citations_projects: [
                  { abstract_screening_results: %i[reasons tags user] },
                  screening_qualifications: :user,
                ],
              )
              .find(id)
    project_info = {
      'Project Attribution' => project.attribution,
      'Project Authors of Report' => project.authors_of_report,
      'Project Methodology Description' => project.methodology_description,
      'Project Prospero Registration Id' => project.prospero,
      'Project Doi' => project.doi,
      'Project Note' => project.notes,
      'Project Funding Source' => project.funding_source,
    }

    project_info['Project Description'] = project.description if !project.description.blank?

    if !project.mesh_descriptors.blank?
      project_info['Project Mesh'] ||= []
      project.mesh_descriptors.each do |mesh|
        project_info['Project Mesh'] << mesh.name
      end
    end

    project_composition = build_composition(project)

    project_info.each do |title, value|
      next if value.blank?

      value = [value] unless value.is_a? Array
      value.each do |v|
        add_section(project_composition, title, v)
      end
    end

    citations = project.citations.includes(:journal).all
    key_questions = project.key_questions_projects.all
    extractions = project.extractions
    sd_meta_data = project.sd_meta_data

    asrs = []
    sqs = []
    project.citations_projects.each do |citation|
      citation.abstract_screening_results.each do |asr|
        asrs << asr if !asr.blank?
      end

      citation.screening_qualifications.each do |sq|
        sqs << sq
      end
    end

    forms = []
    efpss_in_fhir = []
    project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        efps_in_fhir = ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_projects_section_id(efps.id)
        if !efps_in_fhir.blank?
          efpss_in_fhir << efps_in_fhir
          forms << efps
        end
      end
    end

    citations_in_fhir = citations.map { |citation| CitationSupplyingService.new.find_by_citation_id(citation.id) }
    key_questions_in_fhir = key_questions.map { |key_question| KeyQuestionSupplyingService.new.find_by_key_question_id(key_question.id) }
    extractions_in_fhir = project.extractions.map { |extraction| ExtractionSupplyingService.new.find_by_extraction_id(extraction.id) }
    sd_meta_data_in_fhir = sd_meta_data.map { |sd_meta_data| SdMetaDataSupplyingService.new.find_by_sd_meta_data_id(sd_meta_data.id) }
    as_label_in_fhir = AsLabelSupplyingService.new.get_fhir_objs_in_array_by_project_id(id)

    add_reference_section(project_composition, 'Citations', citations, 'Citation', 'Citation') if !citations.blank?
    add_reference_section(project_composition, 'KeyQuestions', key_questions, 'KeyQuestion', 'EvidenceVariable') if !key_questions.blank?
    add_reference_section(project_composition, 'ExtractionFormsProjectsSections', forms, 'ExtractionFormsProjectsSection', 'Questionnaire') if !forms.blank?
    add_reference_section(project_composition, 'Extractions', extractions, 'Extraction', 'List') if !extractions.blank?
    add_reference_section(project_composition, 'SdMetaData', sd_meta_data, 'SdMetaData', 'Bundle') if !sd_meta_data.blank?
    add_reference_section(project_composition, 'AbstractScreeningResults', asrs, 'AbstractScreeningResult', 'ArtifactAssessment') if !asrs.blank?
    add_reference_section(project_composition, 'ScreeningQualifications', sqs, 'ScreeningQualification', 'ArtifactAssessment') if !sqs.blank?

    combination = citations_in_fhir.dup + key_questions_in_fhir.dup + efpss_in_fhir.dup + extractions_in_fhir.dup + sd_meta_data_in_fhir.dup + as_label_in_fhir.dup
    combination.unshift(project_composition)
    bundle = FhirResourceService.get_bundle(fhir_objs: combination, type: 'transaction')

    bundle
  end

  def document_find_by_project_id(id)
    project = Project
              .includes(:mesh_descriptors)
              .includes(:citations)
              .includes(:key_questions_projects)
              .includes(:extractions)
              .includes(:sd_meta_data)
              .includes(extraction_forms_projects: :extraction_forms_projects_sections)
              .find(id)
    project_info = {
      'Project Attribution' => project.attribution,
      'Project Authors of Report' => project.authors_of_report,
      'Project Methodology Description' => project.methodology_description,
      'Project Prospero Registration Id' => project.prospero,
      'Project Doi' => project.doi,
      'Project Note' => project.notes,
      'Project Funding Source' => project.funding_source,
    }

    project_info['Project Description'] = project.description if !project.description.blank?

    if !project.mesh_descriptors.blank?
      project_info['Project Mesh'] ||= []
      project.mesh_descriptors.each do |mesh|
        project_info['Project Mesh'] << mesh.name
      end
    end

    project_composition = build_composition(project)

    project_info.each do |title, value|
      next if value.blank?

      value = [value] unless value.is_a? Array
      value.each do |v|
        add_section(project_composition, title, v)
      end
    end

    citations = project.citations.includes(:journal).all
    key_questions = project.key_questions_projects.all
    extractions = project.extractions
    sd_meta_data = project.sd_meta_data

    forms = []
    efpss_in_fhir = []
    project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        efps_in_fhir = ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_projects_section_id(efps.id)
        if !efps_in_fhir.blank?
          efpss_in_fhir << efps_in_fhir
          forms << efps
        end
      end
    end

    citations_in_fhir = citations.map { |citation| CitationSupplyingService.new.find_by_citation_id(citation.id) }
    key_questions_in_fhir = key_questions.map { |key_question| KeyQuestionSupplyingService.new.find_by_key_question_id(key_question.id) }
    extractions_in_fhir = project.extractions.map { |extraction| ExtractionSupplyingService.new.find_by_extraction_id(extraction.id) }
    sd_meta_data_in_fhir = sd_meta_data.map { |sd_meta_data| SdMetaDataSupplyingService.new.find_by_sd_meta_data_id(sd_meta_data.id) }

    add_reference_section(project_composition, 'Citations', citations, 'Citation', 'Citation') if !citations.blank?
    add_reference_section(project_composition, 'KeyQuestions', key_questions, 'KeyQuestion', 'EvidenceVariable') if !key_questions.blank?
    add_reference_section(project_composition, 'ExtractionFormsProjectsSections', forms, 'ExtractionFormsProjectsSection', 'Questionnaire') if !forms.blank?
    add_reference_section(project_composition, 'Extractions', extractions, 'Extraction', 'List') if !extractions.blank?
    add_reference_section(project_composition, 'SdMetaData', sd_meta_data, 'SdMetaData', 'Bundle') if !sd_meta_data.blank?

    citation_full_url = FhirResourceService.build_full_url(resources: citations_in_fhir, relative_path: 'citations/')
    kq_full_url = FhirResourceService.build_full_url(resources: key_questions_in_fhir, relative_path: 'key_questions/')
    efps_full_url = FhirResourceService.build_full_url(resources: efpss_in_fhir, relative_path: 'extraction_forms_projects_sections/')
    extraction_full_url = FhirResourceService.build_full_url(resources: extractions_in_fhir, relative_path: 'extractions/')
    sd_meta_data_full_url = FhirResourceService.build_full_url(resources: sd_meta_data_in_fhir, relative_path: 'sd_meta_data/')

    combination_full_url = citation_full_url.dup + kq_full_url.dup + efps_full_url.dup + extraction_full_url.dup + sd_meta_data_full_url.dup
    combination_full_url.unshift("https://srdrplus.ahrq.gov/api/v3/projects/#{id}/composition")
    combination = citations_in_fhir.dup + key_questions_in_fhir.dup + efpss_in_fhir.dup + extractions_in_fhir.dup + sd_meta_data_in_fhir.dup
    combination.unshift(project_composition)
    bundle = FhirResourceService.get_bundle(fhir_objs: combination, type: 'document', full_urls: combination_full_url)

    bundle
  end

  def get_composition_by_project_id(id)
    project = Project.find(id)
    project_info = {
      'Project Attribution' => project.attribution,
      'Project Authors of Report' => project.authors_of_report,
      'Project Methodology Description' => project.methodology_description,
      'Project Prospero Registration Id' => project.prospero,
      'Project Doi' => project.doi,
      'Project Note' => project.notes,
      'Project Funding Source' => project.funding_source,
    }

    project_info['Project Description'] = project.description if !project.description.blank?

    if !project.mesh_descriptors.blank?
      project_info['Project Mesh'] ||= []
      project.mesh_descriptors.each do |mesh|
        project_info['Project Mesh'] << mesh.name
      end
    end

    project_composition = build_composition(project)

    project_info.each do |title, value|
      next if value.blank?

      value = [value] unless value.is_a? Array
      value.each do |v|
        add_section(project_composition, title, v)
      end
    end

    citations = project.citations.includes(:journal).all
    key_questions = project.key_questions_projects.all
    extractions = project.extractions
    sd_meta_data = project.sd_meta_data

    forms = []
    project.extraction_forms_projects.each do |efp|
      efp.extraction_forms_projects_sections.each do |efps|
        efps_in_fhir = ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_projects_section_id(efps.id)
        if !efps_in_fhir.blank?
          forms << efps
        end
      end
    end

    add_reference_section(project_composition, 'Citations', citations, 'Citation', 'Citation') if !citations.blank?
    add_reference_section(project_composition, 'KeyQuestions', key_questions, 'KeyQuestion', 'EvidenceVariable') if !key_questions.blank?
    add_reference_section(project_composition, 'ExtractionFormsProjectsSections', forms, 'ExtractionFormsProjectsSection', 'Questionnaire') if !forms.blank?
    add_reference_section(project_composition, 'Extractions', extractions, 'Extraction', 'Bundle') if !extractions.blank?
    add_reference_section(project_composition, 'SdMetaData', sd_meta_data, 'SdMetaData', 'Bundle') if !sd_meta_data.blank?

    project_composition
  end

  private

  def build_composition(project)
    project_title = project.name || 'No project title'
    project_updated_date = project.updated_at.strftime("%Y-%m-%dT%H:%M:%S%:z")

    {
      'resourceType' => 'Composition',
      'status' => 'unknown',
      'id' => "12-#{project.id}",
      'identifier' => FhirResourceService.build_identifier('Project', project.id),
      'type' => { 'text' => 'Project' },
      'date' => project_updated_date,
      'author' => [{ 'display' => 'SRDR+' }],
      'title' => project_title
    }
  end

  def add_section(array_or_hash, title=nil, value=nil, entrys=nil)
    code = { 'coding' => [{ 'code' => title }] } if title
    section = {
      'title' => title,
      'code' => code,
      'text' => {
        'status' => 'generated',
        'div' => "<div xmlns=\"http://www.w3.org/1999/xhtml\">#{value}</div>"
      },
      'entry' => entrys
    }.compact

    if array_or_hash.is_a?(Hash)
      array_or_hash['section'] = (array_or_hash['section'] || []) << section
    else
      array_or_hash << { 'section' => [section] }
    end
    section
  end

  def add_reference_section(composition, title, raw_data, prefix, type)
    id_values = get_identifier_values(raw_data, prefix)

    entrys = id_values.map { |id_value| { 'identifier' => id_value, 'type' => type } }
    add_section(composition, title, nil, entrys)
  end

  def get_identifier_values(raw_data, prefix)
    if raw_data.is_a?(ActiveRecord::Relation)
      raw_data.ids.map do |id|
        {
          'type' => { 'text' => 'SRDR+ Object Identifier' },
          'system' => 'https://srdrplus.ahrq.gov/',
          'value' => "#{prefix}/#{id}"
        }
      end
    else
      raw_data.map do |raw|
        {
          'type' => { 'text' => 'SRDR+ Object Identifier' },
          'system' => 'https://srdrplus.ahrq.gov/',
          'value' => "#{prefix}/#{raw.id}"
        }
      end
    end
  end
end
