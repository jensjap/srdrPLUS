class SimpleExportJob::LegacyExporter < SimpleExportJob::ExporterBase
  include SimpleExportJob::SectionTemplates::Type1SectionsWide
  include SimpleExportJob::SectionTemplates::Type2SectionsWideSrdrStyle
  include SimpleExportJob::SectionTemplates::ResultSectionsWideSrdrStyle2

  def build!
    build_project_information_section
    build_type1_sections_wide
    build_type2_sections_wide_srdr_style
    build_result_sections_wide_srdr_style_2
  end
end
