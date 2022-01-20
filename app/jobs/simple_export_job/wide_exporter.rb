require 'simple_export_job/exporter_base'
require 'simple_export_job/section_templates/type1_sections_wide'
require 'simple_export_job/section_templates/type2_sections_wide'
require 'simple_export_job/section_templates/result_sections_wide'

class WideExporter < ExporterBase
  include Type1SectionsWide
  include Type2SectionsWide
  include ResultSectionsWide

  def build!
    build_project_information_section
    build_type1_sections_wide
    build_type2_sections_wide
    build_result_sections_wide
  end
end