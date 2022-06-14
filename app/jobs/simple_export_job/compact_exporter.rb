class SimpleExportJob::CompactExporter < SimpleExportJob::ExporterBase
  include SimpleExportJob::SectionTemplates::Type1SectionsCompact
  include SimpleExportJob::SectionTemplates::Type2SectionsCompact
  include SimpleExportJob::SectionTemplates::ResultSectionsCompact

  def build!
    build_project_information_section
    build_type1_sections_compact
    build_type2_sections_compact
    build_result_sections_compact
  end
end
