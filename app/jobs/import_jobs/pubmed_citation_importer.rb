module ImportJobs::PubmedCitationImporter
  def import_citations_from_pubmed_file(imported_file, preview = false)
    pmid_arr = imported_file.content.download.split("\n").map { |pmid| pmid.strip }
    import_citations_from_pubmed_array(imported_file.project, pmid_arr, preview)
  end

  def import_citations_from_pubmed_array(project, pubmed_id_array, preview)
    key_counter = 0
    primary_id = CitationType.find_by(name: 'Primary').id

    preview_citations = []
    count = pubmed_id_array.length
    pubmed_id_array = pubmed_id_array[0..2] if preview
    h_arr = []
    Bio::PubMed.efetch(pubmed_id_array).each do |cit_txt|
      row_h = {}
      cit_h = Bio::MEDLINE.new(cit_txt).pubmed
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      row_h['pmid'] = cit_h['PMID'].strip if cit_h['PMID'].present?
      row_h['name'] = cit_h['TI'].strip if cit_h['TI'].present?
      row_h['abstract'] = cit_h['AB'].strip if cit_h['AB'].present?
      row_h['citation_type_id'] = primary_id

      # keywords
      if cit_h['OT'].present?
        kw_str = cit_h['OT']
        kw_str.gsub!(/"/, '')
        kw_arr = kw_str.split('     ')
        kw_arr = kw_str.split(/, |,/) if kw_arr.length == 1
        kw_arr = kw_str.split(/; |;/) if kw_arr.length == 1
        kw_arr = kw_str.split(%r{ / |/}) if kw_arr.length == 1
        kw_arr = kw_str.split(/ \| |\|/) if kw_arr.length == 1
        kw_arr = kw_str.split(/\n/) if kw_arr.length == 1
        row_h['keywords_attributes'] = {}
        kw_arr.each do |kw|
          row_h['keywords_attributes'][Time.now.to_i + key_counter] = { name: kw }
          key_counter += 1
        end
      end

      # authors
      if cit_h['AU'].present?
        au_str = cit_h['AU']
        au_str.gsub!(/"/, '')
        au_arr = au_str.split('     ')
        au_arr = au_str.split(/, |,/) if au_arr.length == 1
        au_arr = au_str.split(%r{ / |/}) if au_arr.length == 1
        au_arr = au_str.split(/ \| |\|/) if au_arr.length == 1
        au_arr = au_str.split(/\n| \n/) if au_arr.length == 1

        row_h['authors'] = au_arr.join(', ')
      end

      # journal
      j_h = {}
      j_h['name'] = cit_h['TA'].strip if cit_h['TA'].present?
      j_h['publication_date'] = cit_h['DP'].strip if cit_h['DP'].present?
      j_h['volume'] = cit_h['VI'].strip if cit_h['VI'].present?
      j_h['issue'] = cit_h['IP'].strip if cit_h['IP'].present?
      row_h['journal_attributes'] = j_h
      s_h = {}
      s_h['name'] = cit_h['TA'].strip if cit_h['TA'].present?
      s_h['volume'] = cit_h['VI'].strip if cit_h['VI'].present?
      s_h['issue'] = cit_h['IP'].strip if cit_h['IP'].present?
      row_h['source'] = s_h
      row_h['publication_date'] = cit_h['DP'].strip if cit_h['DP'].present?

      h_arr << row_h

      next unless h_arr.length >= CITATION_BATCH_SIZE

      if preview
        preview_citations += h_arr.dup
      else
        project.citations << Citation.create(h_arr)
      end
      h_arr = []
    end
    # project.citations << Citation.create!( h_arr )
    { count:, citations: preview_citations }
  end
end
