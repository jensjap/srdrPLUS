class ConsolidationsController < ApplicationController
  def index
    @project = Project.find(params[:project_id])
    @nav_buttons.push('comparison_tool')
    respond_to do |format|
      format.json do
        return render json: project_citations_grouping_hash(@project)
      end
      format.html do
        @citations_grouping_hash = project_citations_grouping_hash(@project)
      end
    end
  end

  def project_citations_grouping_hash(project)
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
      citations_grouping_hash[citation] = {
        citation_id: citation.id,
        extractions: [],
        consolidated_extraction: nil,
        citation_title: "#{citation.author_map_string}: #{citation.name}",
        reference_checksum: nil,
        differences: false
      }
    end

    extractions.each do |extraction|
      if extraction.consolidated
        citations_grouping_hash[extraction.citation][:consolidated_extraction] = extraction
      else
        citations_grouping_hash[extraction.citation][:extractions] << extraction
        checksum = extraction.extraction_checksum
        checksum = checksum.update_hexdigest if checksum.is_stale
        citations_grouping_hash[extraction.citation][:reference_checksum] ||= checksum
        if citations_grouping_hash[extraction.citation][:reference_checksum] != checksum
          citations_grouping_hash[extraction.citation][:differences] = true
        end
      end
    end
    citations_grouping_hash
  end
end

# e1_checksum = extraction1.extraction_checksum
# e2_checksum = extraction2.extraction_checksum

# e1_checksum.update_hexdigest if e1_checksum.is_stale
# e2_checksum.update_hexdigest if e2_checksum.is_stale
