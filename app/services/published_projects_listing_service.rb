class PublishedProjectsListingService
  def initialize
  end

  def set_export_path(relative_path)
    @export_path = Rails.root.join(relative_path)
  end

  def parse_and_print_projects_info
    raise "Export path not set" unless @export_path

    projects_info = []

    Dir.glob(File.join(@export_path, "*.xlsx")).each do |file_path|
      file_name = File.basename(file_path, ".xlsx")
      # Example: project_3564_1744144196_advanced.xlsx
      # Extract project id and export timestamp
      match = file_name.match(/^project_(\d+)_(\d+)_/)
      project_id = match[1] if match
      export_timestamp = match[2] if match

      next unless project_id

      project = Project.find_by(id: project_id)
      next unless project

      export_info = {
        public_download_url: "/exports/#{file_name}.xlsx", # Adjust as needed
        export_timestamp: export_timestamp ? Time.at(export_timestamp.to_i) : nil
      }

      info = {
        id: project.id,
        name: project.name,
        description: project.description,
        created_at: project.created_at,
        updated_at: project.updated_at,
        export: export_info
      }
      projects_info << info
    end

    puts projects_info.to_json
  end
end
