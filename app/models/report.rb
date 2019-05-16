class Report
  @ReportMetaStruct ||= Struct.new(:title, :publisher, :pub_year, :accession_id, :last_updated)

  def self.all
    ReportFetcher.read_list_of_cer_report_metas.map do |meta_hash|
      @ReportMetaStruct.new(
        meta_hash['Title'],
        meta_hash['Publisher'],
        meta_hash['Publication Year'],
        meta_hash['Accession ID'],
        meta_hash['Last Updated (YYYY-MM-DD HH:MM:SS)']
      )
    end
  end
end