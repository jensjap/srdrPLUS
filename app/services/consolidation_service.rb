class ConsolidationService
  def self.project_citations_grouping_hash(project)
    citations_grouping_hash = {}
    citations = project.citations
    extractions =
      project
      .extractions
      .includes(
        :extraction_checksum,
        statusing: :status,
        citations_project: { citation: { authors_citations: %i[
          author ordering
        ] } }
      )
    citations.each do |citation|
      citations_grouping_hash[citation.id] = {
        extractions: [],
        consolidated_extraction: nil,
        citation_title: "#{citation.author_map_string}: #{citation.name}",
        reference_checksum: nil,
        differences: false,
        consolidated_extraction_status: nil
      }
    end

    extractions.each do |extraction|
      if extraction.consolidated
        citations_grouping_hash[extraction.citation.id][:consolidated_extraction] = extraction
        citations_grouping_hash[extraction.citation.id][:consolidated_extraction_status] = extraction.status.name
      else
        citations_grouping_hash[extraction.citation.id][:extractions] << extraction
        checksum = extraction.extraction_checksum
        checksum = checksum.update_hexdigest if checksum.is_stale
        citations_grouping_hash[extraction.citation.id][:reference_checksum] ||= checksum.hexdigest
        if citations_grouping_hash[extraction.citation.id][:reference_checksum] != checksum.hexdigest
          citations_grouping_hash[extraction.citation.id][:differences] = true
        end
      end
    end
    citations_grouping_hash
  end
end
