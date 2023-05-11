module ImportJobs::EnlCitationImporter
  def import_citations_from_enl(imported_file, preview = false)
    key_counter = 0
    primary_id = CitationType.find_by(name: 'Primary').id

    # creates a new parser of type EndNote
    parser = RefParsers::EndNoteParser.new

    file_string = imported_file.content.download

    preview_citations = []
    h_arr = []
    parser.parse(file_string).each do |cit_h|
      row_h = {}
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      ## NOT SURE ABOUT PMID KEY
      row_h['pmid'] = cit_h['M'].strip if cit_h['M'].present?
      row_h['name'] = cit_h['T'].strip if cit_h['T'].present?
      row_h['abstract'] = cit_h['X'].strip if cit_h['X'].present?
      row_h['citation_type_id'] = primary_id

      # keywords
      if cit_h['K'].present?
        ### splitting kw strings still a huge pain
        kw_arr = []
        kw_arr = if cit_h['K'].is_a? Enumerable
                   cit_h['K']
                 else
                   cit_h['K'].split('     ')
                 end
        kw_arr = cit_h['K'].split(/, |,/) if kw_arr.length == 1
        kw_arr = cit_h['K'].split(/; |;/) if kw_arr.length == 1
        kw_arr = cit_h['K'].split(%r{ / |/}) if kw_arr.length == 1
        kw_arr = cit_h['K'].split(/ \| |\|/) if kw_arr.length == 1
        kw_arr = cit_h['K'].split(/\n/) if kw_arr.length == 1

        row_h['keywords_attributes'] = {}
        kw_arr.each do |kw|
          row_h['keywords_attributes'][Time.now.to_i + key_counter ] = { name: kw }
          key_counter += 1
        end
      end

      # there are other tags for authors
      ['A'].each do |au_key|
        next unless cit_h[au_key].present?

        au_arr = []
        au_arr = if cit_h[au_key].is_a? Enumerable
                   cit_h[au_key]
                 else
                   cit_h[au_key].split('     ')
                 end
        row_h['authors'] = au_arr.join(', ')
      end

      # journal
      j_h = {}
      j_h['name'] = cit_h['B'].strip if cit_h['B'].present?
      j_h['publication_date'] = cit_h['D'].strip if cit_h['D'].present?
      j_h['volume'] = cit_h['V'].strip if cit_h['V'].present?
      j_h['issue'] = cit_h['I'].strip if cit_h['I'].present?
      row_h['journal_attributes'] = j_h

      h_arr << row_h

      next unless h_arr.length >= CITATION_BATCH_SIZE

      if preview
        preview_citations += h_arr.dup
      else
        imported_file.project.citations << Citation.create(h_arr)
      end
      h_arr = []
    end
    # imported_file.project.citations << Citation.create!( h_arr )
    { count: preview_citations.length, citations: preview_citations[0..2] }
  end
end
