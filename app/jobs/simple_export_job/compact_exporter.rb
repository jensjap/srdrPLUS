require 'simple_export_job/exporter_base'
require 'simple_export_job/section_templates/type1_sections_compact'
require 'simple_export_job/section_templates/type2_sections_compact'
require 'simple_export_job/section_templates/result_sections_compact'

class CompactExporter < ExporterBase
  include Type1SectionsCompact
  include Type2SectionsCompact
  include ResultSectionsCompact

  def build!
    build_project_information_section
    build_type1_sections_compact
    build_type2_sections_compact
    build_result_sections_compact
  end
end