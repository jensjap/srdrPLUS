require 'simple_export_job/exporter_base'
require 'simple_export_job/section_templates/type1_sections_wide'
require 'simple_export_job/section_templates/type2_sections_wide_srdr_style'
require 'simple_export_job/section_templates/result_sections_wide_srdr_style_2'

class LegacyExporter < ExporterBase
  include Type1SectionsWide
  include Type2SectionsWideSRDRStyle
  include ResultSectionsWideSRDRStyle2

  def build!
    build_project_information_section
    build_type1_sections_wide
    build_type2_sections_wide_srdr_style
    build_result_sections_wide_srdr_style_2
  end
end