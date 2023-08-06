PRIMARY_ID = CitationType.find_by(name: 'Primary').id

module ImportJobs::PubmedCitationImporter
  def import_citations_from_pubmed_file(imported_file, preview: false)
    pmid_arr = imported_file.content.download.split("\n").map(&:strip).compact_blank
    import_citations_from_pubmed_array(imported_file.project, pmid_arr, preview)
  end

  def import_citations_from_pubmed_array(project, pubmed_id_array, preview)
    count = pubmed_id_array.length
    pubmed_id_array = pubmed_id_array[0..4] if preview

    preview_citations = process_pubmed_ids(project, pubmed_id_array, preview)

    { count:, citations: preview_citations }
  end

  private

  def process_pubmed_ids(project, pubmed_id_array, preview)
    preview_citations = []

    search_results = find_existing_and_missing_citation_records(pubmed_id_array)
    existing_citations = search_results[:existing]
    missing_citations = search_results[:missing]

    h_arr_missing_citations = efetch(missing_citations)
    all_citations = existing_citations + h_arr_missing_citations

    # This puts citations into the correct order.
    pubmed_id_array.each do |pmid|
      preview_citations.concat(all_citations.select { |citation| citation['pmid'] == pmid })
    end

    unless preview
      Citation.create(h_arr_missing_citations)
      pubmed_id_array.each do |pmid|
        CitationsProject.find_or_create_by!(project:, citation: Citation.find_by(pmid:))
      end
    end

    preview_citations
  end

  def find_existing_and_missing_citation_records(pubmed_id_array)
    lsof_pmid_in_system = []
    lsof_pmid_missing = []

    pubmed_id_array.each do |pmid|
      citation = Citation.find_by(pmid:)
      if citation
        lsof_pmid_in_system << citation
      else
        lsof_pmid_missing << pmid
      end
    end

    # Careful: the return hash is mixed. lsof_pmid_in_system is an array
    # of Citation objects, while lsof_pmid_missing is an array of strings.
    { existing: lsof_pmid_in_system, missing: lsof_pmid_missing }
  end

  def efetch(pubmed_id_array)
    key_counter = 0
    h_arr = []

    # This will return an array with a single element if none of the PMIDs in the input
    # are valid.
    pubmed_id_array.each_slice(10000) do |batched_pubmed_id_array|
      Bio::PubMed.efetch(batched_pubmed_id_array).each do |cit_txt|
        row_h = {}
        cit_h = Bio::MEDLINE.new(cit_txt).pubmed

        # If none of the PMIDs in the input are valid then we get
        # {
        #   "ID+l" => "t+is+empty!+Possibly+it+has+no+correct+IDs."
        # }
        # Use break here in case the next batch has valid PMIDs.
        break if cit_h.key?('ID+l')

        # will add as primary citation by default, there is no way to figure that out from pubmed
        row_h['pmid'] = cit_h['PMID'].strip if cit_h['PMID'].present?
        row_h['name'] = cit_h['TI'].strip.truncate(500) if cit_h['TI'].present?
        row_h['abstract'] = cit_h['AB'].strip if cit_h['AB'].present?
        row_h['citation_type_id'] = PRIMARY_ID

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

        h_arr << row_h
      end  # Bio::PubMed.efetch(batched_pubmed_id_array).each do |cit_txt|
    end  # pubmed_id_array.each_slice(10000) do |batched_pubmed_id_array|

    h_arr
  end  # def efetch(pubmed_id_array)
end
