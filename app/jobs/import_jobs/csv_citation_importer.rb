require 'csv'
require 'cgi'

module ImportJobs::CsvCitationImporter
  def import_citations_from_csv(imported_file, user_id, import_id, preview = false)
    primary_id = CitationType.find_by(name: 'Primary').id
    ### citation type, not sure if necessary
    # secondary_id = CitationType.find_by( name: 'Secondary' ).id
    #
    # row_d = { 'Primary' => primary_id, 'primary' => primary_id,
    #          'Secondary' => secondary_id, 'secondary' => secondary_id,
    #          '' => nil }

    preview_citations = []
    h_arr = []

    file_string = imported_file.content.download.encode("UTF-8", invalid: :replace, undef: :replace, replace: "")
    @project = imported_file.project

    CSV.parse(file_string, headers: :true, skip_blanks: true) do |row|
      row = sanitize_row(row)
      key_counter   = 0
      row_h         = row.to_h
      cit_h         = {}

      cit_h['citation_type_id'] = primary_id

      # RefId.
      refid_str = row_h['refid']
      cit_h['refid'] = refid_str if refid_str.present?
      cit_h['refman'] = refid_str if refid_str.present?

      # authors.
      au_str = row_h['authors']
      if au_str.present?
        au_str.gsub!(/"/, '')
        au_arr = au_str.split('     ')
        au_arr = au_str.split(/, |,/) if au_arr.length == 1
        au_arr = au_str.split(%r{ / |/}) if au_arr.length == 1
        au_arr = au_str.split(/ \| |\|/) if au_arr.length == 1
        au_arr = au_str.split(/\n| \n/) if au_arr.length == 1
        cit_h['authors'] = au_arr.join(', ')
      end

      # title.
      cit_h['name'] = row_h['title'].strip if row_h['title'].present?

      # abstract.
      cit_h['abstract'] = row_h['abstract'].strip if row_h['abstract'].present?

      # accession number.
      cit_h['accession_number'] = row_h['accession number'].strip if row_h['accession number'].present?

      # pmid.
      cit_h['pmid'] = row_h['pmid'].strip if row_h['pmid'].present?

      # doi.
      cit_h['doi'] = row_h['doi'].strip if row_h['doi'].present?

      # journal.
      j_h = {}
      j_h['name'] = row_h['journal'].strip if row_h['journal'].present?
      j_h['publication_date'] = row_h['year'].strip if row_h['year'].present?
      j_h['volume'] = row_h['volume'].strip if row_h['volume'].present?
      j_h['issue'] = row_h['issue'].strip if row_h['issue'].present?
      cit_h['journal_attributes'] = j_h

      # keywords.
      kw_str = row_h['keywords']
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

      h_arr << cit_h

      if h_arr.length >= CITATION_BATCH_SIZE
        if preview
          preview_citations += h_arr.dup
        else
          h_arr.each do |arr|
            find_or_create_citation_and_make_association_to_project(arr, user_id)
          end
        end
        h_arr = []
      end
    end

    { count: preview_citations.length, citations: preview_citations[0..2] }
  end

  def find_or_create_citation_and_make_association_to_project(arr, user_id)
    rel_citations = Citation.where("doi=?", arr['doi'].to_s) if arr['doi'].present?
    rel_citations = Citation.where("pmid=?", arr['pmid'].to_s) if arr['pmid'].present?
    citation = if rel_citations.present?
                 rel_citations.first
               else
                 refid = arr.delete('refid') if arr.has_key?('refid')
                 citation = Citation.create(arr)
                 citation.update(citation_type_id: 1)
                 citation
               end
    @project.citations << citation
    citations_project = @project.citations_projects.find_by(citation_id: citation.id)
    citations_project.update(refman: refid, creator_id: user_id, import_type: 'csv', import_id: import_id)
  end

  def sanitize_row(row)
    # Sanitize headers
    sanitized_headers = {}
    row.headers.each do |header|
      sanitized_header = CGI.escapeHTML(header.strip)
      # Remove BOM from the sanitized header if it exists
      sanitized_header.gsub!(/^\xEF\xBB\xBF/, '')
      sanitized_headers[sanitized_header] = header
    end

    # Iterate through each row
    row.each do |key, value|
      # Remove BOM from the value if it exists
      value.gsub!(/^\xEF\xBB\xBF/, '') if value.is_a?(String)

      # Sanitize the value to prevent code injection
      row[key] = CGI.escapeHTML(value) if value.is_a?(String)
    end

    row.headers.each_with_object({}) { |header, hash| hash[sanitized_headers[header].downcase] = row[header] }
  end
end
