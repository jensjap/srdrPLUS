module ImportJobs::PubmedCitationImporter
  def import_citations_from_pubmed_file(imported_file)
    pmid_arr = imported_file.content.download.split("\n").map { |pmid| pmid.strip }
    import_citations_from_pubmed_array imported_file.project, pmid_arr
  end

  def import_citations_from_pubmed_array(project, pubmed_id_array)
    key_counter = 0
    primary_id = CitationType.find_by(name: 'Primary').id

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
        row_h['authors_citations_attributes'] = {}
        au_arr.each_with_index do |au, position|
          row_h['authors_citations_attributes'][Time.now.to_i + key_counter] =
            { author_attributes: { name: au }, ordering_attributes: { position: (position + 1) } }
          key_counter += 1
        end
      end

      # journal
      j_h = {}
      j_h['name'] = cit_h['TA'].strip if cit_h['TA'].present?
      j_h['publication_date'] = cit_h['DP'].strip if cit_h['DP'].present?
      j_h['volume'] = cit_h['VI'].strip if cit_h['VI'].present?
      j_h['issue'] = cit_h['IP'].strip if cit_h['IP'].present?
      row_h['journal_attributes'] = j_h

      h_arr << row_h

      if h_arr.length >= CITATION_BATCH_SIZE
        project.citations << Citation.create(h_arr)
        h_arr = []
      end
    end
    # project.citations << Citation.create!( h_arr )
  end
end
