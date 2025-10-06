require 'fileutils'
require 'parallel'

class ArchiveService
  PUBLISHED_PATH = 'tmp/archives/published'
  UNPUBLISHED_PATH = 'tmp/archives/unpublished'
  SIMPLE_EXPORTS_PATH = 'tmp/simple_exports'

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
end