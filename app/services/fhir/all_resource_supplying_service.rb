class AllResourceSupplyingService

  def find_by_project_id(id)
    project = Project.find(id)
    project_info = {
      'project_name' => project.name,
      'project_attribution' => project.attribution,
      'project_authors_of_report' => project.authors_of_report,
      'project_methodology_description' => project.methodology_description,
      'project_prospero_registration_id' => project.prospero,
      'project_doi' => project.doi,
      'project_note' => project.notes,
      'project_funding_source' => project.funding_source,
    }

    project_info['project_description'] = project.description if !project.description.blank?

    if !project.mesh_descriptors.blank?
      project_info['project_mesh'] ||= []
      project.mesh_descriptors.each do |mesh|
        project_info['project_mesh'] << mesh.name
      end
    end

    efpss = []
    project.extraction_forms_projects.each do |efp|
      efpss.append(ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_project_id(efp.id))
    end
    forms = FhirResourceService.get_bundle(fhir_objs: efpss, type: 'collection')
    citations = CitationSupplyingService.new.find_by_project_id(id)
    key_questions = KeyQuestionSupplyingService.new.find_by_project_id(id)
    extractions = ExtractionSupplyingService.new.find_by_project_id(id)

    link_info = [
      {
        'relation' => 'tag',
        'url' => 'api/v3/projects/' + id.to_s
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/project.txt'
      }
    ]
    project_info['bundle'] = FhirResourceService.get_bundle(fhir_objs: [forms, citations, key_questions, extractions], type: 'collection', link_info: link_info)

    FhirResourceService.deep_clean(project_info)
  end
end
