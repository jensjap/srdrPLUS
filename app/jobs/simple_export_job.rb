class SimpleExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  rescue_from(StandardError) do |exception|
    Sentry.capture_exception(exception) if Rails.env.production?
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second, exception.message).deliver_later
  end

  def perform(*args)
    Axlsx::Package.new do |package|
      @user_email = args.first
      @project = Project
                 .includes({
                             extractions: {
                               citations_project: { citation: :journal }
                             },
                             extraction_forms_projects: {
                               extraction_forms_projects_sections: [
                                 :section,
                                 :extraction_forms_projects_section_option,
                                 { extractions_extraction_forms_projects_sections: {
                                   extractions_extraction_forms_projects_sections_type1s: :type1
                                 } }
                               ]
                             }
                           })
                 .find(args.second)
      @export_type = args.third
      @package = package
      @package.use_shared_strings = true
      @package.use_autowidth = true
      @highlight = @package.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14,
                                                      font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      @wrap = @package.workbook.styles.add_style alignment: { wrap_text: true }

      Rails.logger.debug "#{self.class.name}: I'm performing my job with arguments: #{args.inspect}"
      Rails.logger.debug "#{self.class.name}: Working on project: #{@project.name}"

      # Generate XLSX with basic project information.
      filename = generate_xlsx_and_filename
      raise 'Unable to serialize' unless @package.serialize(filename)

      raise 'Unknown ExportType.' unless /xlsx/ =~ @export_type

      create_email_export(filename)

      ExportMailer.notify_simple_export_completion(@exported_item.id).deliver_later
    end
  end

  private

  def generate_xlsx_and_filename
    if /wide/ =~ @export_type
      exporter = WideExporter.new(@package, @project, @highlight, @wrap)
      exporter.build!
      'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_wide.xlsx'
    elsif /legacy/ =~ @export_type
      exporter = LegacyExporter.new(@package, @project, @highlight, @wrap)
      exporter.build!
      'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_legacy.xlsx'
    else
      exporter = CompactExporter.new(@package, @project, @highlight, @wrap)
      exporter.build!
      'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '_long.xlsx'
    end
  end

  def create_email_export(filename)
    @export_type = ExportType.find_by(name: '.xlsx')
    @exported_item = ExportedItem.create! project: @project, user_email: @user_email, export_type: @export_type
    @exported_item.file.attach(io: File.open(filename), filename:)
    # Notify the user that the export is ready for download.
    raise 'Cannot attach exported file' unless @exported_item.file.attached?

    @exported_item.external_url = Rails.application.routes.default_url_options[:host] + Rails.application.routes.url_helpers.rails_blob_path(
      @exported_item.file, only_path: true
    )
    @exported_item.save!
  end
end
