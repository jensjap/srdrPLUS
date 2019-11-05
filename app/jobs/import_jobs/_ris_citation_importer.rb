def import_citations_from_ris(imported_file)
  key_counter = 0
  primary_id = CitationType.find_by( name: 'Primary' ).id

  # creates a new parser of type RIS
  parser = RefParsers::RISParser.new

  file_data = imported_file.content.download.gsub(/(\r\n|\r|\n)/, "\n")
  file_string = ""
  ### open file using 'rU'
  file_data.split("\n").each do |line|
    file_string += ( line.strip_control_and_extended_characters + "\n" )
  end

  h_arr = []
  parser.parse( file_string ).each do |cit_h|
    row_h = {}
    ### will add as primary citation by default, there is no way to figure that out from pubmed
    ## NOT SURE ABOUT PMID KEY
    #
    if cit_h[ 'ID' ].present? then row_h[ 'refman' ] = cit_h[ 'ID' ].strip end
    if cit_h[ 'AN' ].present? then row_h[ 'pmid' ] = cit_h[ 'AN' ].strip end
    if cit_h[ 'TI' ].present? then row_h[ 'name' ] = cit_h[ 'TI' ].strip end
    if cit_h[ 'T1' ].present? then row_h[ 'name' ] = cit_h[ 'T1' ].strip end
    if cit_h[ 'AB' ].present? then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
    row_h[ 'citation_type_id' ] = primary_id

    #keywords
    if cit_h[ 'KW' ].present?
      ### splitting kw strings still a huge pain
      if cit_h[ 'KW' ].is_a? Enumerable
        kw_arr = cit_h[ 'KW' ]
      else
        kw_arr = cit_h[ 'KW' ].split( "     " )
      end
      if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( /, |,/ ) end
      if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( /; |;/ ) end
      if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( / \/ |\// ) end
      if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( / \| |\|/ ) end
      if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( /\n/ ) end
      row_h[ 'keywords_attributes' ] = {}
      kw_arr.each do |kw|
        row_h[ 'keywords_attributes' ][Time.now.to_i + key_counter ] = { name: kw }
        key_counter += 1
      end
    end

    row_h[ 'authors_citations_attributes' ] = {}

    ##authors
    #if cit_h[ 'AU' ].present?
    #  au_arr = cit_h[ 'AU' ]
    #  au_arr.each do |au|
    #    row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
    #    key_counter+=1
    #  end
    #end

    #there are other tags for authors
    [ "A1", "A2", "A3", "A4", "AU" ].each do |au_key|
      if cit_h[ au_key ].present?
        au_arr = []
        if cit_h[ au_key ].is_a? Enumerable
          au_arr = cit_h[ au_key ]
        else
          au_arr = cit_h[ au_key ].split( "     " )
        end
        au_arr.each_with_index do |au, position|
          row_h[ 'authors_citations_attributes' ][Time.now.to_i + key_counter] = { author_attributes: { name: au }, ordering_attributes: { position: (position + 1) } }
          key_counter += 1
        end
      end
    end

    #journal
    j_h = {}
    if cit_h[ 'T2' ].present? then j_h[ 'name' ] = cit_h[ 'T2' ].strip end
    if cit_h[ 'JF' ].present? then j_h[ 'name' ] = cit_h[ 'JF' ].strip end
    if cit_h[ 'JO' ].present? then j_h[ 'name' ] = cit_h[ 'JO' ].strip end
    if cit_h[ 'PY' ].present? then j_h[ 'publication_date' ] = cit_h[ 'PY' ].strip end
    if cit_h[ 'Y1' ].present? then j_h[ 'publication_date' ] = cit_h[ 'Y1' ].strip end
    if cit_h[ 'VL' ].present? then j_h[ 'volume' ] = cit_h[ 'VL' ].strip end
    if cit_h[ 'IS' ].present? then j_h[ 'issue' ] = cit_h[ 'IS' ].strip end
    row_h[ 'journal_attributes' ] = j_h

    h_arr << row_h
  end

  imported_file.project.citations << Citation.create!( h_arr )
end
