module ExportTypes
    RIS = 'RIS'
end

class CitationsExportService
    def initialize(type, project_id, lsof_citation_ids=[])
        @type = type
        @project_id = project_id
        @lsof_citation_ids = lsof_citation_ids
    end

    def export
        citations_projects = get_citations_projects(@project_id, @lsof_citation_ids)
        citations = transform_for_export(citations_projects)
        payload = nil
        case @type
        when ExportTypes::RIS
            payload = export_payload_in_ris(citations)
        else
            raise 'UnknownExportType'
        end
        puts payload
    end

    private

    def get_citations_projects(project_id, citation_ids)
        project = Project.find project_id
        if citation_ids.blank?
            citations_projects = project.citations_projects
        else
            project.citations_projects.where(citation_id: citation_ids)
        end
    end

    def transform_for_export(citations_projects)
        citations = []
        citations_projects.each do |cp|
            citation_template = {}
            citation_template.default = nil

            citation_template[:srdr_citation_id]          = cp.citation.id
            citation_template[:title]                     = cp.citation.name.strip
            citation_template[:pmid]                      = cp.citation.pmid
            citation_template[:abstract]                  = cp.citation.abstract.delete("\r\n\\").strip
            citation_template[:page_start]                = cp.citation.page_number_start
            citation_template[:page_end]                  = cp.citation.page_number_end
            citation_template[:registry_number]           = cp.citation.registry_number
            citation_template[:doi]                       = cp.citation.doi
            citation_template[:accession_no]              = cp.citation.accession_number
            citation_template[:author_string]             = cp.citation.authors
            citation_template[:journal]                   = cp.citation.journal&.name
            citation_template[:volume]                    = cp.citation.journal&.volume
            citation_template[:issue]                     = cp.citation.journal&.issue
            citation_template[:publication_date]          = cp.citation.journal&.publication_date
            citation_template[:srdr_citations_project_id] = cp.id
            citation_template[:refman]                    = cp.refman
            citation_template[:other_reference]           = cp.other_reference
            citation_template[:updated_at]                = cp.updated_at

            citations << citation_template
        end

        citations
    end
end
