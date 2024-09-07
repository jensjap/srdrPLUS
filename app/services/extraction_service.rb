class ExtractionService
  # Same User, CitationsProject combination is allowed.

  # return [INT] processed_citations_count
  #        [EXTRACTION] succeeded
  #        [EXTRACTION] skipped
  #        [EXTRACTION] failed
  def self.bulk_assignment_duplicates_allowed(user, project, lsof_citation_ids, duplicates_allowed: false)
    processed_citations_count = 0
    succeeded = []
    skipped = []
    failed = []
    
    lsof_citation_ids
      .delete_if { |el| el.nil? || el.to_s.strip.empty? }
      .map(&:to_i).each do |citation_id|

      processed_citations_count += 1

      citations_project = CitationsProject.find_by(citation_id:, project:)

      if duplicates_allowed
        new_extraction = project
                         .extractions
                         .build(
                           citations_project:,
                           user:)
        if new_extraction.save
          succeeded << new_extraction
        else
          failed << new_extraction
        end

      else
        new_extraction = project
                         .extractions
                         .find_or_initialize_by(
                           citations_project:,
                           user:)
        if new_extraction.persisted?
          skipped << new_extraction
        elsif new_extraction.save
          succeeded << new_extraction
        else
          failed << new_extraction
        end
      end
    end

    return processed_citations_count, succeeded, skipped, failed
  end
end