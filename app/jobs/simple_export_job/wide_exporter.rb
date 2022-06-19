class SimpleExportJob::WideExporter < SimpleExportJob::ExporterBase
  include SimpleExportJob::SectionTemplates::Type1SectionsWide
  include SimpleExportJob::SectionTemplates::Type2SectionsWide
  include SimpleExportJob::SectionTemplates::ResultSectionsWide

  def build!
    build_project_information_section
    build_type1_sections_wide
    build_type2_sections_wide
    build_result_sections_wide
  end
end
