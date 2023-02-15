class MigratingAuthorsService
  def self.migrate_authors!
    time do
      Citation.includes(authors_citations: %i[author ordering]).find_in_batches do |citation_group|
        author_objects = []
        citation_group.each do |citation|
          authors = citation.authors_citations.map do |ac|
            [ac.ordering&.position || 999_999, ac.author.name]
          end.sort { |a, b| (a[0] || 0) <=> (b[0] || 0) }.map { |a| a[1] }.join(', ')[0..4999]

          author_objects << {
            id: citation.id,
            authors:
          }
        end
        Citation.upsert_all(author_objects)
      end
    end
  end

  def self.migrate_authors_check
    time do
      correct = 0
      incorrect = 0
      Citation.includes(authors_citations: %i[author ordering]).find_in_batches do |citation_group|
        author_objects = []
        citation_group.each do |citation|
          authors = citation.authors_citations.map do |ac|
            [ac.ordering&.position || 999_999, ac.author.name]
          end.sort { |a, b| (a[0] || 0) <=> (b[0] || 0) }.map { |a| a[1] }.join(', ')[0..4999]

          if citation.read_attribute(:authors) == authors
            correct += 1
          else
            incorrect += 1
          end
        end
      end
      puts "correct: #{correct}"
      puts "incorrect: #{incorrect}"
    end
  end

  def self.time
    start_time = Time.now
    puts start_time
    yield
    end_time = Time.now
    time_diff = start_time - end_time
    puts Time.at(time_diff.to_i.abs).utc.strftime '%H:%M:%S'
  end
end
