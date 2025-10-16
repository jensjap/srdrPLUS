class CustomExportJob
  HEADERS = %w[srdrid
               pmid
               refman
               title
               abstract
               authors
               journal
               volume
               issue
               pages
               accession_number
               doi
               ref
               publication_date
               publication_year
               publication_month
               keywords].freeze

  def self.start_all
    project_ids = [5148]
    export_citations(project_ids)
    export_asr_data(project_ids)
  end

  def self.export_citations(project_ids)
    citations = Citation.includes(:journal, :keywords,
                                  :citations_projects).where(citations_projects: { project_id: project_ids })
    filepath = Rails.root.join('tmp', "#{project_ids.join(', ')}:citations_export_#{Time.now}.csv")

    CSV.open(filepath, 'wb', headers: true, quote_char: '"', force_quotes: true) do |csv|
      csv << HEADERS

      citations.each do |citation|
        csv << [
          or_empty_string(citation.id),
          or_empty_string(citation.pmid),
          or_empty_string(citation.refman),
          or_empty_string(citation.name),
          or_empty_string(citation.abstract),
          or_empty_string(citation.authors),
          or_empty_string(citation.journal&.name),
          or_empty_string(citation.journal&.volume),
          or_empty_string(citation.journal&.issue),
          or_empty_string(''),
          or_empty_string(citation.accession_number),
          or_empty_string(citation.doi),
          or_empty_string(citation.refman),
          or_empty_string(citation.journal&.publication_date),
          or_empty_string(citation.journal&.publication_date),
          or_empty_string(''),
          or_empty_string(citation.keywords.map(&:name).join(', '))
        ]
      end
    end

    puts "CSV exported to #{filepath}"
  end

  def self.export_asr_data(project_ids)
    asrs = AbstractScreeningResult.includes(:tags, :user,
                                            citations_project: :citation).where(citations_projects: { project_id: project_ids })
    ass = AbstractScreening.includes(word_weights: :user).where(project_id: project_ids)
    export_labels(project_ids, asrs)
    export_tags(project_ids, asrs)
    export_notes(project_ids, asrs)
    export_terms(project_ids, ass)
  end

  def self.export_labels(project_ids, asrs)
    filepath = Rails.root.join('tmp', "#{project_ids.join(', ')}:labels_export_#{Time.now}.csv")
    CSV.open(filepath, 'wb', headers: true, quote_char: '"', force_quotes: true) do |csv|
      csv << %w[srdrid value email]

      asrs.each do |asr|
        csv << [
          or_empty_string(asr.citation.id),
          or_empty_string(asr.label),
          or_empty_string(asr.user.email)
        ]
      end
    end
  end

  def self.export_tags(project_ids, asrs)
    filepath = Rails.root.join('tmp', "#{project_ids.join(', ')}:tags_export_#{Time.now}.csv")
    CSV.open(filepath, 'wb', headers: true, quote_char: '"', force_quotes: true) do |csv|
      csv << %w[srdrid name email]

      asrs.each do |asr|
        asr.tags.each do |tag|
          csv << [
            or_empty_string(asr.citation.id),
            or_empty_string(tag.name),
            or_empty_string(asr.user.email)
          ]
        end
      end
    end
  end

  def self.export_notes(project_ids, asrs)
    filepath = Rails.root.join('tmp', "#{project_ids.join(', ')}:notes_export_#{Time.now}.csv")
    CSV.open(filepath, 'wb', headers: true, quote_char: '"', force_quotes: true) do |csv|
      csv << %w[srdrid general email]

      asrs.each do |asr|
        csv << [
          or_empty_string(asr.citation.id),
          or_empty_string(asr.notes),
          or_empty_string(asr.user.email)
        ]
      end
    end
  end

  def self.export_terms(project_ids, ass)
    filepath = Rails.root.join('tmp', "#{project_ids.join(', ')}:terms_export_#{Time.now}.csv")
    CSV.open(filepath, 'wb', headers: true, quote_char: '"', force_quotes: true) do |csv|
      csv << %w[project_id name value email]

      ass.each do |as|
        as.word_weights.each do |word_weight|
          csv << [
            or_empty_string(''),
            or_empty_string(word_weight.word),
            or_empty_string(word_weight.weight),
            or_empty_string(word_weight.user.email)
          ]
        end
      end
    end
  end

  def self.or_empty_string(input)
    input || ''
  end
end
