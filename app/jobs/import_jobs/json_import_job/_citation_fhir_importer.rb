class CitationFhirImporter
  def initialize(project_id, citation)
    @project       = Project.find project_id
    @citation_json = citation
  end

  def run
    citation_hash = {
      citation_type:     CitationType.find_by(name: "Primary"),
      name:              @citation_json.fetch("articleTitle", ""),
      refman:            "",
      pmid:              @citation_json.fetch("medlinePubMed", {}).fetch("pmid", ""),
      abstract:          @citation_json.fetch("abstract", ""),
      page_number_start: @citation_json.fetch("pagination", {}).fetch("firstPage", ""),
      page_number_end:   @citation_json.fetch("pagination", {}).fetch("lastPage", "")}

    citation_by_pmid = Citation.find_by(pmid: @citation_json.fetch("medlinePubMed", {}).fetch("pmid", ""))
    if citation_by_pmid
      @project.citations << citation_by_pmid
      return
    end

    Citation.transaction do
      @project.citations_projects << CitationsProject.create(
        citation: Citation.find_or_create_by(citation_hash),
        project: @project)
    end
  end
end