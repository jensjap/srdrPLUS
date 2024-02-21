class CitationSupplyingService

  def find_by_project_id(project_id)
    citations = Project
                .find(project_id)
                .citations
                .includes(:journal)
                .all
    link_info = [
      {
        'relation' => 'tag',
        'url' => 'api/v3/projects/' + project_id.to_s + '/citations'
      },
      {
        'relation' => 'service-doc',
        'url' => 'doc/fhir/citation.txt'
      }
    ]

    citations = citations.map { |citation| create_fhir_obj(citation) }
    bundle = FhirResourceService.get_bundle(objs=citations, type='collection', link_info=link_info)

    return 'Error in validation' unless FhirResourceService.validate_resource(bundle)
    bundle.to_json
  end

  def find_by_citation_id(citation_id)
    citation = Citation.find(citation_id)
    citation_in_fhir = create_fhir_obj(citation)

    return 'Error in validation' unless FhirResourceService.validate_resource(citation_in_fhir)

    citation_in_fhir.to_json
  end

  private

  def create_fhir_obj(raw)
    citation = FhirResourceService.get_citation(
      '1', # id_prefix
      raw.id, # srdrplus_id
      'Citation', # srdrplus_type
      'active', # status
      raw.name.present? ? raw.name : nil, # title
      raw.abstract.present? ? raw.abstract : nil, # abstract
      raw.authors.present? ? raw.authors : nil, # authors
      raw.pmid.present? ? raw.pmid : nil, # pmid
      raw.journal&.publication_date, # journal_publication_date
      raw.journal&.volume, # journal_volume
      raw.journal&.issue, # journal_issue
      raw.journal&.name # journal_published_in
    )

    citation
  end
end
