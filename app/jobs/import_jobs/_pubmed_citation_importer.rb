def import_citations_from_pubmed_file(imported_file)
  pmid_arr = imported_file.content.download.split("\n").map{|pmid| pmid.strip}
  import_citations_from_pubmed_array imported_file.project, pmid_arr
end

def import_citations_from_pubmed_array(project, pubmed_id_array)
  key_counter = 0
  primary_id = CitationType.find_by( name: 'Primary' ).id

  h_arr = []
  Bio::PubMed.efetch( pubmed_id_array ).each do |cit_txt|
    row_h = {}
    cit_h = Bio::MEDLINE.new( cit_txt ).pubmed
    ### will add as primary citation by default, there is no way to figure that out from pubmed
    if cit_h[ 'PMID' ].present? then row_h[ 'pmid' ] = cit_h[ 'PMID' ].strip end
    if cit_h[ 'TI' ].present? then row_h[ 'name' ] = cit_h[ 'TI' ].strip end
    if cit_h[ 'AB' ].present? then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
    row_h[ 'citation_type_id' ] = primary_id

    #keywords
    if cit_h[ 'OT' ].present?
      kw_str = cit_h[ 'OT' ]
      kw_str.gsub! /"/, ''
      kw_arr = kw_str.split( "     " )
      if kw_arr.length == 1 then kw_arr = kw_str.split( /, |,/ ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( / \/ |\// ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( / \| |\|/ ) end
      if kw_arr.length == 1 then kw_arr = kw_str.split( /\n| \n/ ) end
      row_h[ 'keywords_attributes' ] = {}
      kw_arr.each do |kw|
        row_h[ 'keywords_attributes' ][Time.now.to_i + key_counter] = { name: kw }
        key_counter+=1
      end
    end

    #authors
    if cit_h[ 'AU' ].present?
      au_str = cit_h[ 'AU' ]
      au_str.gsub! /"/, ''
      au_arr = au_str.split( "     " )
      if au_arr.length == 1 then au_arr = au_str.split( /, |,/ ) end
      if au_arr.length == 1 then au_arr = au_str.split( / \/ |\// ) end
      if au_arr.length == 1 then au_arr = au_str.split( / \| |\|/ ) end
      if au_arr.length == 1 then au_arr = au_str.split( /\n| \n/ ) end
      row_h[ 'authors_attributes' ] = {}
      au_arr.each do |au|
        row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
        key_counter+=1
      end
    end

    #journal
    j_h = {}
    if cit_h[ 'TA' ].present? then j_h[ 'name' ] = cit_h[ 'TA' ].strip end
    if cit_h[ 'DP' ].present? then j_h[ 'publication_date' ] = cit_h[ 'DP' ].strip end
    if cit_h[ 'VI' ].present? then j_h[ 'volume' ] = cit_h[ 'VI' ].strip end
    if cit_h[ 'IP' ].present? then j_h[ 'issue' ] = cit_h[ 'IP' ].strip end
    row_h[ 'journal_attributes' ] = j_h

    h_arr << row_h
  end
  project.citations << Citation.create!( h_arr )
end