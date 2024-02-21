class AllResourceSupplyingService

  def find_by_project_id(id)
    require 'json'
    project = Project.find(id)
    project_info = {
      'project_name' => project.name,
      'project_description' => project.description,
      'project_attribution' => project.attribution,
      'project_authors_of_report' => project.authors_of_report,
      'project_methodology_description' => project.methodology_description,
      'project_prospero_registration_id' => project.prospero,
      'project_doi' => project.doi,
      'project_note' => project.notes,
      'project_funding_source' => project.funding_source,
      'project_mesh' => []
    }
    for mesh in project.mesh_descriptors do
      project_info['project_mesh'].append(mesh.name)
    end

    efpss = []
    for efp in project.extraction_forms_projects do
      efpss.append(ExtractionFormsProjectsSectionSupplyingService.new.find_by_extraction_forms_project_id(efp.id))
    end
    forms = create_bundle(objs=efpss, type='collection')
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
    all_resource = create_bundle(objs=[forms, citations, key_questions, extractions], type='collection', link_info=link_info)
    project_info['bundle'] = all_resource
    return project_info.to_json
  end

  private

  def create_bundle(fhir_objs, type, link_info=nil)
    bundle = {
      'type' => type,
      'link' => link_info,
      'entry' => []
    }

    for fhir_obj in fhir_objs do
      bundle['entry'].append({ 'resource' => fhir_obj }) if fhir_obj
    end

    FHIR::Bundle.new(bundle)
  end

end
