require '_se_project_information_section'
require '_se_type1_sections_compact'
require '_se_type1_sections_wide'
require '_se_type2_sections'
require '_se_result_sections'
require '_se_sample_3d_pie_chart'

class SimpleExportJob < ApplicationJob
  require 'axlsx'

  queue_as :default

  def perform(*args)
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"
    @project = Project.find args.first
    @user = User.find args.second
    Rails.logger.debug "#{ self.class.name }: Working on project: #{ @project.name }"

    Axlsx::Package.new do |p|
      p.use_shared_strings = true
      highlight = p.workbook.styles.add_style bg_color: 'C7EECF', fg_color: '09600B', sz: 14, font_name: 'Calibri (Body)'
      wrap      = p.workbook.styles.add_style alignment: { wrap_text: true }

      # Sheet with basic project information.
      build_project_information_section(p, @project, highlight, wrap)

      # Type 1s - compact format.
      build_type1_sections_compact(p, @project, highlight, wrap)

      # Type 1s - wide format.
      build_type1_sections_wide(p, @project, highlight, wrap)

      # Type 2s.
      build_type2_sections(p, @project)

      # Results.
      build_result_sections(p, @project)

      # Default sample 3D pie chart.
      build_sample_3d_pie_chart(p)

      p.serialize('simple.xlsx')

      # Notify the user that the export is ready for download.
      ExportMailer.notify_simple_export_completion(@user.id, @project.id).deliver_later
    end
  end
end
