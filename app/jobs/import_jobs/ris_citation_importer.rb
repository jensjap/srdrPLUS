module ImportJobs::RisCitationImporter
  def import_citations_from_ris(imported_file, preview = false)
    key_counter = 0

    # creates a new parser of type RIS
    parser = RefParsers::RISParser.new

    # !!! maybe just gsub double quotes with single quotes.
    file_string = imported_file
                  .content
                  .download
                  .gsub('"', "'")
                  .encode(
                    'UTF-8',
                    invalid: :replace,
                    undef: :replace,
                    replace: '',
                    universal_newline: true
                  )

    return false unless file_string

    preview_citations = []
    h_arr = []
    successful_refman_arr = []
    failed_refman_arr = []
    parser.parse(file_string).each do |cit_h|
      h_arr << get_row_hash(cit_h, key_counter)
      # CITATION_BATCH_SIZE is defined in config/initializers/sidekiq.rb
      if h_arr.length >= CITATION_BATCH_SIZE
        begin
          if preview
            preview_citations += h_arr.dup
          else
            imported_file.project.citations << Citation.create!(h_arr)
          end
          successful_refman_arr << h_arr.map { |h| h[:refman] }
        rescue StandardError
          failed_refman_arr << h_arr.map { |h| h[:refman] }
        end
        h_arr.clear
      end
      cit_h.clear
    end
    # imported_file.project.citations << Citation.create(h_arr)
    if preview
      { count: preview_citations.length, citations: preview_citations[0..2] }
    else
      { imported_refmans: successful_refman_arr, failed_refmans: failed_refman_arr }
    end
  end

  def get_row_hash(cit_h, key_counter)
    primary_id = CitationType.find_by(name: 'Primary').id.freeze
    ### will add as primary citation by default, there is no way to figure that out from pubmed
    ## NOT SURE ABOUT PMID KEY
    #

    row_h = {}
    au_arr = []
    j_h = {}

    row_h['refman'] = cit_h['ID'].strip if cit_h['ID'].present?
    row_h['pmid'] = cit_h['AN'].strip if cit_h['AN'].present?
    row_h['name'] = cit_h['TI'].strip if cit_h['TI'].present?
    row_h['name'] = cit_h['T1'].strip if cit_h['T1'].present?
    row_h['abstract'] = cit_h['AB'].strip if cit_h['AB'].present?
    row_h['citation_type_id'] = primary_id

    # keywords
    if cit_h['KW'].present?
      ### splitting kw strings still a huge pain
      kw_arr = if cit_h['KW'].is_a? Enumerable
                 cit_h['KW']
               else
                 cit_h['KW'].split('     ')
               end
      kw_arr = cit_h['KW'].split(/, |,/) if kw_arr.length == 1
      kw_arr = cit_h['KW'].split(/; |;/) if kw_arr.length == 1
      kw_arr = cit_h['KW'].split(%r{ / |/}) if kw_arr.length == 1
      kw_arr = cit_h['KW'].split(/ \| |\|/) if kw_arr.length == 1
      kw_arr = cit_h['KW'].split(/\n/) if kw_arr.length == 1
      row_h['keywords_attributes'] = {}
      kw_arr.each do |kw|
        row_h['keywords_attributes'][Time.now.to_i + key_counter] = { name: kw }
        key_counter += 1
      end
    end

    # there are other tags for authors
    %w[A1 A2 A3 A4 AU].freeze.each do |au_key|
      next unless cit_h[au_key].present?

      au_arr = if cit_h[au_key].is_a? Enumerable
                 cit_h[au_key]
               else
                 cit_h[au_key].split('     ')
               end
      row_h['authors'] = au_arr.join(', ')
    end

    # journal
    j_h['name'] = cit_h['T2'].strip if cit_h['T2'].present?
    j_h['name'] = cit_h['JF'].strip if cit_h['JF'].present?
    j_h['name'] = cit_h['JO'].strip if cit_h['JO'].present?
    j_h['publication_date'] = cit_h['PY'].strip if cit_h['PY'].present?
    j_h['publication_date'] = cit_h['Y1'].strip if cit_h['Y1'].present?
    if cit_h.has_key?('VL')
      cit_h['VL'].is_a?(Array) ? (j_h['volume'] = cit_h['VL'].join(' ')) : (j_h['volume'] = cit_h['VL'].try(:strip))
    end
    j_h['issue'] = cit_h['IS'].strip if cit_h['IS'].present?
    row_h['journal_attributes'] = j_h

    row_h
  end
end
