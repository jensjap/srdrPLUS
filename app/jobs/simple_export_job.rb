require 'simple_export_job/_se_project_information_section'
require 'simple_export_job/_se_type1_sections_compact'
require 'simple_export_job/_se_type1_sections_wide'
require 'simple_export_job/_se_type2_sections_compact'
require 'simple_export_job/_se_type2_sections_wide'
require 'simple_export_job/_se_result_sections_compact'
require 'simple_export_job/_se_result_sections_wide'
require 'simple_export_job/_se_sample_3d_pie_chart'

class SimpleExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  rescue_from(StandardError) do |exception|
       # Do something with the exception
    ExportMailer.notify_simple_export_failure(arguments.first, arguments.second, exception.message).deliver_later
  end

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    @project = Project.find args.second
    @user = User.find args.first
    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"

    Axlsx::Package.new do |p|
      p.use_shared_strings = true
      p.use_autowidth      = true
      highlight  = p.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)', alignment: { wrap_text: true }
      wrap       = p.workbook.styles.add_style alignment: { wrap_text: true }

      # Sheet with basic project information.
      build_project_information_section(p, @project, highlight, wrap)

      # Type 1s - compact format.
#      build_type1_sections_compact(p, @project, highlight, wrap)

      # Type 1s - wide format.
      build_type1_sections_wide(p, @project, highlight, wrap)

      # Type 2s - compact format.
#      build_type2_sections_compact(p, @project, highlight, wrap)

      # Type 2s - wide format.
      build_type2_sections_wide(p, @project, highlight, wrap)

      # Results - compact format.
#      build_result_sections_compact(p, @project, highlight, wrap)

      # Results - wide format.
      build_result_sections_wide(p, @project, highlight, wrap)

      # Default sample 3D pie chart.
      build_sample_3d_pie_chart(p)

      f_name = 'tmp/simple_exports/project_' + @project.id.to_s + '_' + Time.now.strftime('%s') + '.xlsx'
      if p.serialize(f_name)
        exported_item = ExportedItem.create! projects_user: ProjectsUser.find_by(project: @project, user: @user), export_type: ExportType.find_by(name: '.xlsx')
        exported_item.file.attach io: File.open(f_name), filename: f_name
        # Notify the user that the export is ready for download.
        if exported_item.file.attached?
          ExportMailer.notify_simple_export_completion(exported_item.id).deliver_later
        else
          raise "Cannot save exported file"
        end
      end
    end
  end
end
