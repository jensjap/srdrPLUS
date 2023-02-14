module ImportJobs::CsvCitationImporter
  def import_citations_from_csv(imported_file)
    primary_id = CitationType.find_by(name: 'Primary').id
    ### citation type, not sure if necessary
    # secondary_id = CitationType.find_by( name: 'Secondary' ).id
    #
    # row_d = { 'Primary' => primary_id, 'primary' => primary_id,
    #          'Secondary' => secondary_id, 'secondary' => secondary_id,
    #          '' => nil }

    h_arr = []

    file_string = imported_file.content.download.encode('UTF-8', invalid: :replace, undef: :replace, replace: '',
                                                                 universal_newline: true)

    CSV.parse(file_string, headers: :true) do |row|
      key_counter = 0
      row_h = row.to_h
      cit_h = {}

      ### file encoding causes weird problems

      ### citation type, not sure if necessary
      # cit_type = row_h[ 'type' ]
      # if cit_type.present?
      #  row_h[ 'citation_type_id' ] = row_d[ cit_type ]
      # else
      #  row_h[ 'citation_type_id' ] = primary_id
      # end
      # row_h.delete 'type'
      cit_h['citation_type_id'] = primary_id

      ### keywords
      kw_str = row_h['Keywords']
      if kw_str.present?
        kw_str.gsub!(/"/, '')
        kw_arr = kw_str.split('     ')
        kw_arr = kw_str.split(/, |,/) if kw_arr.length == 1
        kw_arr = kw_str.split(/; |;/) if kw_arr.length == 1
        kw_arr = kw_str.split(%r{ / |/}) if kw_arr.length == 1
        kw_arr = kw_str.split(/ \| |\|/) if kw_arr.length == 1
        kw_arr = kw_str.split(/\n/) if kw_arr.length == 1

        cit_h['keywords_attributes'] = {}
        kw_arr.each do |kw|
          cit_h['keywords_attributes'][Time.now.to_i + key_counter] = { name: kw }
          key_counter += 1
        end
      end

      ### authors
      au_str = row_h['Authors']
      if au_str.present?
        au_str.gsub!(/"/, '')
        au_arr = au_str.split('     ')
        au_arr = au_str.split(/, |,/) if au_arr.length == 1
        au_arr = au_str.split(%r{ / |/}) if au_arr.length == 1
        au_arr = au_str.split(/ \| |\|/) if au_arr.length == 1
        au_arr = au_str.split(/\n| \n/) if au_arr.length == 1
        cit_h['authors'] = au_arr.join(', ')
      end

      ### journal
      j_h = {}
      j_h['name'] = row_h['Journal'].strip if row_h['Journal'].present?
      j_h['publication_date'] = row_h['Year'].strip if row_h['Year'].present?
      j_h['volume'] = row_h['Volume'].strip if row_h['Volume'].present?
      j_h['issue'] = row_h['Issue'].strip if row_h['Issue'].present?
      cit_h['journal_attributes'] = j_h

      cit_h['name'] = row_h['Title'].strip if row_h['Title'].present?
      cit_h['abstract'] = row_h['Abstract'].strip if row_h['Abstract'].present?
      cit_h['pmid'] = row_h['Accession Number'].strip if row_h['Accession Number'].present?

      h_arr << cit_h

      if h_arr.length >= CITATION_BATCH_SIZE
        imported_file.project.citations << Citation.create(h_arr)
        h_arr = []
      end
    end
    # imported_file.project.citations << Citation.create( h_arr )
  end
end
