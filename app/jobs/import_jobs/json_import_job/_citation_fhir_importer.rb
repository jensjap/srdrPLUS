class CitationFhirImporter
  def initialize(project_id, citation)
    @project       = Project.find project_id
    @citation_json = citation
  end

  def run
    citation = nil
    pmid = @citation_json.fetch("medlinePubMed", {}).fetch("pmid", nil) || fetch_pmid_from_identifiers

    citation_hash = {
      citation_type:     CitationType.find_by(name: "Primary"),
      name:              @citation_json.fetch("articleTitle", ""),
      refman:            "",
      pmid:              pmid,
      abstract:          @citation_json.fetch("abstract", ""),
      page_number_start: @citation_json.fetch("pagination", {}).fetch("firstPage", ""),
      page_number_end:   @citation_json.fetch("pagination", {}).fetch("lastPage", "")
    }

    journal_hash = {
      volume: @citation_json.fetch("journal", {}).fetch("journalIssue", {}).fetch("volume", ""),
      issue:  @citation_json.fetch("journal", {}).fetch("journalIssue", {}).fetch("issue", ""),
      name:   @citation_json.fetch("journal", {}).fetch("title", {}),
      publication_date: @citation_json.fetch("journal", {}).fetch("journalIssue", {}).fetch("publicationDate", {}).fetch("text", "")
    }

    citation = Citation.find_by(pmid: pmid) if pmid.present?
    if citation.present?
      @project.citations << citation
    else
      citation = Citation.find_or_create_by(citation_hash)
      @project.citations_projects << CitationsProject.create(
        citation: citation,
        project: @project)
    end

    journal = Journal.find_or_create_by(journal_hash)
    citation.journal = journal unless citation.journal.present?
  end  # END def run

  private

    def fetch_pmid_from_identifiers
      @citation_json["identifier"].each do |idx, identifier|
        if identifier["system"].eql?("https://www.ncbi.nlm.nih.gov/pubmed/")
          return identifier["value"]
        end
      end

      return nil
    end

    def fetch_doi_from_identifiers
      @citation_json["identifier"].each do |idx, identifier|
        if identifier["system"].eql?("https://doi.org")
          return identifier["value"]
        end
      end

      return nil
    end
end