class PublishedProjectsListingService
  def initialize
  end

  def parse_and_print_projects_info
    export_path = ENV['PUBLISHED_EXPORT_PATH']
    raise "Export path not set" if export_path.nil? || export_path.strip.empty?

    projects_info = []

    Dir.glob(File.join(export_path, "*.xlsx")).each do |file_path|
      file_name = File.basename(file_path, ".xlsx")
      # Example: project_3564_1744144196_advanced.xlsx
      # Extract project id and export timestamp
      match = file_name.match(/^project_(\d+)_(\d+)_/)
      project_id = match[1] if match
      export_timestamp = match[2] if match

      next unless project_id

      # when loading project, consider preloading associations to avoid N+1:
      project = Project.includes(:key_questions, :extraction_forms, :citations_projects => :citation).find_by(id: project_id)
      next unless project

      # before fetching project, build public prefix and parse filename
      public_prefix = ENV['PUBLIC_DOWNLOAD_URL_PREFIX'] || "/exports"
      export_info = {
        public_download_url: "#{public_prefix}/#{file_name}.xlsx",
        export_timestamp: export_timestamp ? Time.at(export_timestamp.to_i) : nil
      }

      # Additional fields requested
      attribution = project.respond_to?(:attribution) ? project.attribution : nil
      authors_of_report = if project.respond_to?(:authors_of_report)
        project.authors_of_report
      elsif project.respond_to?(:authors)
        project.authors
      else
        nil
      end
      methodology_description = project.respond_to?(:methodology_description) ? project.methodology_description : nil
      prospero = if project.respond_to?(:prospero)
        project.prospero
      elsif project.respond_to?(:prospero_id)
        project.prospero_id
      else
        nil
      end
      doi = project.respond_to?(:doi) ? project.doi : nil
      notes = project.respond_to?(:notes) ? project.notes : nil
      funding_source = project.respond_to?(:funding_source) ? project.funding_source : nil

      # key_questions: normalize to an array of { name, created_at } using actual model attributes
      key_questions = []
      if project.respond_to?(:key_questions_projects) && project.key_questions_projects.respond_to?(:map)
        key_questions = project.key_questions_projects.map do |kqp|
          {
            name: kqp.key_question&.name,
            created_at: kqp.created_at
          }
        end
      end

      associated_extraction_forms = []
      if project.respond_to?(:extraction_forms_projects) && project.extraction_forms_projects.respond_to?(:map)
        associated_extraction_forms = project.extraction_forms_projects.map do |efp|
          {
            name: efp.extraction_form&.name,
            type: efp.extraction_forms_project_type&.name
          }
        end
      end

      associated_studies = []
      # Use the Citation model attributes directly:
      # title => citation.name, authors => citation.authors, year => citation.year
      if project.respond_to?(:citations_projects) && project.citations_projects.respond_to?(:each)
        project.citations_projects.each do |cp|
          citation = cp.respond_to?(:citation) ? cp.citation : nil
          next unless citation

          associated_studies << {
            title: citation.name,
            authors: citation.authors,
            year: citation.year,
            doi: citation.doi,
            pmid: citation.pmid
          }
        end
      elsif project.respond_to?(:citations) && project.citations.respond_to?(:map)
        associated_studies = project.citations.map do |citation|
          {
            title: citation.name,
            authors: citation.authors,
            year: citation.year,
            doi: citation.doi,
            pmid: citation.pmid
          }
        end
      end

      info = {
        id: project.id,
        name: project.name,
        description: project.respond_to?(:description) ? project.description : nil,
        attribution: attribution,
        authors_of_report: authors_of_report,
        methodology_description: methodology_description,
        prospero: prospero,
        doi: doi,
        notes: notes,
        funding_source: funding_source,
        key_questions: key_questions,
        associated_extraction_forms: associated_extraction_forms,
        associated_studies: associated_studies,
        created_at: project.created_at,
        updated_at: project.updated_at,
        export: export_info
      }
      projects_info << info
    end

    puts projects_info.to_json
  end
end
