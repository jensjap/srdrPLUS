require 'fileutils'
require 'parallel'

class ArchiveService
  ARCHIVES_ROOT_PATH         = 'tmp/archives'
  PUBLISHED_PATH             = 'tmp/archives/published'
  UNPUBLISHED_PATH           = 'tmp/archives/unpublished'
  SIMPLE_EXPORTS_PATH        = 'tmp/simple_exports'
  PUBLIC_DOWNLOAD_URL_PREFIX = ENV.fetch('PUBLIC_DOWNLOAD_URL_PREFIX') # Raises KeyError if not set

  def self.export_all_projects(email:, parallel: 3)
    FileUtils.mkdir_p(PUBLISHED_PATH)
    FileUtils.mkdir_p(UNPUBLISHED_PATH)

    error_log_path = 'log/archive_service_errors.log'

    project_ids = Project.pluck(:id)

    Parallel.each(project_ids, in_processes: parallel) do |project_id|
      next if project_id.eql?(2847) # Skip problematic project
      begin
        project = Project.find(project_id)
        is_published = project.publishing.present? && project.publishing.approval.present?
        dest_dir = is_published ? PUBLISHED_PATH : UNPUBLISHED_PATH
        FileUtils.mkdir_p(dest_dir)

        # Check if an export already exists for this project in the destination
        existing_export = Dir.glob(File.join(dest_dir, "project_#{project_id}_*_advanced.xlsx")).any?
        if existing_export
          Rails.logger.info "Skipping project #{project_id}: export already exists."
          next
        end

        AdvancedExportJob.perform_now(email, project_id)
        # Find the latest export file for this project
        pattern = File.join(SIMPLE_EXPORTS_PATH, "project_#{project_id}_*_advanced.xlsx")
        export_file = Dir.glob(pattern).max_by { |f| File.mtime(f) }
        next unless export_file && File.exist?(export_file)

        FileUtils.mv(export_file, dest_dir)

        # Free memory for this process
        GC.start
      rescue => e
        File.open(error_log_path, 'a') do |f|
          f.puts "[#{Time.now}] Failed to export project #{project_id}: #{e.message}"
          f.puts e.backtrace.join("\n")
          f.puts "-" * 80
        end
        Rails.logger.error "Failed to export project #{project_id}: #{e.message}"
      end
    end
  end

  def self.parse_and_print_published_projects_info
    raise "Export path not set" unless UNPUBLISHED_PATH

    projects_info = []

    Dir.glob(File.join(UNPUBLISHED_PATH, "*.xlsx")).each do |file_path|
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
        public_download_url: "#{PUBLIC_DOWNLOAD_URL_PREFIX}#{file_name}.xlsx",
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

    # Save JSON to file in ARCHIVES_ROOT_PATH
    FileUtils.mkdir_p(ARCHIVES_ROOT_PATH)
    File.open(File.join(ARCHIVES_ROOT_PATH, "projects_info.json"), "w") do |f|
      f.write(projects_info.to_json)
    end
  end
end