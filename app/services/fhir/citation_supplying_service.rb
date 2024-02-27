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
    bundle = FhirResourceService.get_bundle(fhir_objs: citations, type: 'collection', link_info: link_info)

    bundle
  end

  def find_by_citation_id(citation_id)
    citation = Citation.find(citation_id)
    citation_in_fhir = create_fhir_obj(citation)

    citation_in_fhir
  end

  private

  def create_fhir_obj(raw)
    citation = FhirResourceService.get_citation(
      id_prefix: '1',
      srdrplus_id: raw.id,
      srdrplus_type: 'Citation',
      status: 'active',
      title: raw.name.present? ? raw.name : nil,
      abstract: raw.abstract.present? ? raw.abstract : nil,
      authors: raw.authors.present? ? raw.authors : nil,
      pmid: raw.pmid.present? ? raw.pmid : nil,
      journal_publication_date: raw.journal&.publication_date,
      journal_volume: raw.journal&.volume,
      journal_issue: raw.journal&.issue,
      journal_published_in: raw.journal&.name
    )

    citation
  end
end
