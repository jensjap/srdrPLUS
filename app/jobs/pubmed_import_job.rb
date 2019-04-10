class PubmedImportJob < ApplicationJob
  queue_as :default

  def perform(*args)
    # ARGS: user_id, project_id, file_path
    #
    # Do something later
    Rails.logger.debug "#{ self.class.name }: I'm performing my job with arguments: #{ args.inspect }"

    @user = User.find( args.first )
    @project = Project.find( args.second )

    key_counter = 0
    pmid_arr = File.readlines( args.third )
    primary_id = CitationType.find_by( name: 'Primary' ).id

    h_arr = []
    Bio::PubMed.efetch( pmid_arr ).each do |cit_txt|
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
    @project.citations << Citation.create!( h_arr )
  end

  def import_citations_from_ris( file )
    key_counter = 0
    primary_id = CitationType.find_by( name: 'Primary' ).id

    # creates a new parser of type RIS
    parser = RefParsers::RISParser.new

    file_data = File.read( file.path ).gsub(/(\r\n|\r|\n)/, "\n")
    file_string = ""
    ### open file using 'rU'
    file_data.split("\n").each do |line|
      file_string += ( line.strip_control_and_extended_characters() + "\n" )
    end

    h_arr = []
    parser.parse( file_string ).each do |cit_h|
      row_h = {}
      ### will add as primary citation by default, there is no way to figure that out from pubmed
      ## NOT SURE ABOUT PMID KEY
      if cit_h[ 'AN' ].present? then row_h[ 'pmid' ] = cit_h[ 'AN' ].strip end
      if cit_h[ 'TI' ].present? then row_h[ 'name' ] = cit_h[ 'TI' ].strip end
      if cit_h[ 'T1' ].present? then row_h[ 'name' ] = cit_h[ 'T1' ].strip end
      if cit_h[ 'AB' ].present? then row_h[ 'abstract' ] = cit_h[ 'AB' ].strip end
      row_h[ 'citation_type_id' ] = primary_id

      #keywords
      if cit_h[ 'KW' ].present?
        ### splitting kw strings still a huge pain
        kw_arr = []
        if cit_h[ 'KW' ].is_a? Enumerable
          kw_arr = cit_h[ 'KW' ]
        else
          kw_arr = cit_h[ 'KW' ].split( "     " )
        end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( /, |,/ ) end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( / \/ |\// ) end
        if kw_arr.length == 1 then kw_arr = cit_h[ 'KW' ].split( / \| |\|/ ) end
        row_h[ 'keywords_attributes' ] = {}
        kw_arr.each do |kw|
          row_h[ 'keywords_attributes' ] [Time.now.to_i + key_counter ] = { name: kw }
          key_counter += 1
        end
      end

      row_h[ 'authors_attributes' ] = {}

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
          au_arr.each do |au|
            row_h[ 'authors_attributes' ][Time.now.to_i + key_counter] = { name: au }
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
    self.citations << Citation.create!( h_arr )

    ImportMailer.notify_import_completion(@user.id, @project.id).deliver_later
  end
end

