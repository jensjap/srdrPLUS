# Service to detect potential duplicate citations within a project
# Supports comparison by multiple fields: title, authors, accession_number, publication_year
# Supports fuzzy matching using Levenshtein distance for title and authors
class CitationDuplicateDetector
  COMPARISON_FIELDS = %w[title authors accession_number publication_year].freeze
  DEFAULT_COMPARISON_FIELDS = %w[title].freeze
  FUZZY_MATCHABLE_FIELDS = %w[title authors].freeze

  attr_reader :project, :comparison_fields, :fuzzy_threshold

  # @param project [Project] The project to search for duplicates
  # @param comparison_fields [Array<String>] Fields to use for comparison (default: ['title'])
  # @param fuzzy_threshold [Hash] Similarity thresholds for fuzzy matching (0.0-1.0, where 1.0 = exact match)
  #   Example: { title: 0.9, authors: 0.85 }
  #   A threshold of 0.9 means strings must be 90% similar to match
  def initialize(project, comparison_fields: DEFAULT_COMPARISON_FIELDS, fuzzy_threshold: {})
    @project = project
    @comparison_fields = validate_comparison_fields(comparison_fields)
    @fuzzy_threshold = fuzzy_threshold
  end

  # Find all duplicate groups within the project
  # @return [Array<Hash>] Array of duplicate groups with format:
  #   [{
  #     signature: { field1: value1, field2: value2 },
  #     citations_projects: [cp1, cp2, ...],
  #     count: 2
  #   }]
  def find_duplicates
    return [] if project.citations_projects.empty?

    # Eager load associations to avoid N+1 queries
    citations_projects = project.citations_projects
                                .includes(:citation, :project)
                                .to_a

    # If using fuzzy matching, use pairwise comparison
    if uses_fuzzy_matching?
      find_duplicates_fuzzy(citations_projects)
    else
      # Use exact grouping (faster)
      find_duplicates_exact(citations_projects)
    end
  end

  # Check if a specific citation has duplicates in the project
  # @param citation [Citation] The citation to check
  # @return [Array<CitationsProject>] Other citations_projects that are duplicates
  def find_duplicates_for_citation(citation)
    signature = generate_signature(citation)

    project.citations_projects
           .includes(:citation)
           .select { |cp| generate_signature(cp.citation) == signature && cp.citation_id != citation.id }
  end

  # Generate a duplicate detection signature for a citation
  # @param citation [Citation] The citation to generate signature for
  # @return [Hash] Signature hash with normalized field values
  def generate_signature(citation)
    signature = {}

    comparison_fields.each do |field|
      signature[field.to_sym] = normalize_field_value(citation, field)
    end

    signature
  end

  private

  def uses_fuzzy_matching?
    fuzzy_threshold.any?
  end

  def find_duplicates_exact(citations_projects)
    # Group by comparison signature
    groups = citations_projects.group_by { |cp| generate_signature(cp.citation) }

    # Filter to only groups with 2+ items and format results
    groups.select { |_, cps| cps.size > 1 }
          .map do |signature, cps|
            {
              signature: signature,
              citations_projects: cps.sort_by { |cp| cp.citation.id },
              count: cps.size
            }
          end
          .sort_by { |group| -group[:count] }
  end

  def find_duplicates_fuzzy(citations_projects)
    # OPTIMIZATION 1: Pre-filter using exact matching to reduce comparisons
    # Group by exact signature first, then apply fuzzy within/across groups
    exact_groups = citations_projects.group_by { |cp|
      # Use first 50 chars of normalized title as bucket
      title = normalize_field_value(cp.citation, 'title')
      title ? title[0...50] : 'no_title'
    }

    # Build groups using pairwise fuzzy comparison within buckets
    groups = []
    processed = Set.new

    exact_groups.values.each do |bucket|
      bucket.each_with_index do |cp1, i|
        next if processed.include?(cp1.id)

        # Start a new group with this citation
        group = [cp1]
        processed.add(cp1.id)

        # Compare with remaining citations in this bucket
        bucket[(i + 1)..-1].each do |cp2|
          next if processed.include?(cp2.id)

          if citations_similar?(cp1.citation, cp2.citation)
            group << cp2
            processed.add(cp2.id)
          end
        end

        # OPTIMIZATION 2: Also check adjacent buckets (in case prefix differs)
        # This catches cases where "The Study" vs "A Study" might be in different buckets
        if group.size == 1 && fuzzy_threshold.values.max > 0.8
          exact_groups.values.each do |other_bucket|
            next if other_bucket == bucket

            other_bucket.each do |cp2|
              next if processed.include?(cp2.id)

              if citations_similar?(cp1.citation, cp2.citation)
                group << cp2
                processed.add(cp2.id)
              end
            end
          end
        end

        # Only include groups with 2+ citations
        if group.size > 1
          groups << {
            signature: generate_signature(group.first.citation),
            citations_projects: group.sort_by { |cp| cp.citation.id },
            count: group.size
          }
        end
      end
    end

    groups.sort_by { |group| -group[:count] }
  end

  def citations_similar?(citation1, citation2)
    comparison_fields.all? do |field|
      value1 = normalize_field_value(citation1, field)
      value2 = normalize_field_value(citation2, field)

      # Both nil/blank = match
      next true if value1.blank? && value2.blank?
      # One nil/blank = no match
      next false if value1.blank? || value2.blank?

      # Check if this field should use fuzzy matching
      if fuzzy_threshold[field.to_sym] && FUZZY_MATCHABLE_FIELDS.include?(field)
        similarity = calculate_similarity(value1, value2)
        similarity >= fuzzy_threshold[field.to_sym]
      else
        # Exact match
        value1 == value2
      end
    end
  end

  def calculate_similarity(str1, str2)
    return 1.0 if str1 == str2
    return 0.0 if str1.empty? || str2.empty?

    # OPTIMIZATION 3: Early exit if length difference is too large
    # If strings differ by more than 20% in length, similarity can't be high
    len_diff = (str1.length - str2.length).abs.to_f
    max_length = [str1.length, str2.length].max
    return 0.0 if len_diff / max_length > 0.3

    # Calculate Levenshtein distance
    distance = DidYouMean::Levenshtein.distance(str1, str2)

    # Convert distance to similarity (0.0 to 1.0)
    1.0 - (distance.to_f / max_length)
  end

  def validate_comparison_fields(fields)
    invalid_fields = fields - COMPARISON_FIELDS
    unless invalid_fields.empty?
      raise ArgumentError, "Invalid comparison fields: #{invalid_fields.join(', ')}. Valid fields are: #{COMPARISON_FIELDS.join(', ')}"
    end

    fields.empty? ? DEFAULT_COMPARISON_FIELDS : fields
  end

  def normalize_field_value(citation, field)
    value = case field
            when 'title'
              citation.name
            when 'authors'
              citation.authors
            when 'accession_number'
              # Check both pmid and refman fields
              citation.pmid.presence || citation.refman.presence
            when 'publication_year'
              extract_year_from_citation(citation)
            end

    # Normalize: downcase, strip whitespace, nil if blank
    value.to_s.strip.downcase.presence
  end

  def extract_year_from_citation(citation)
    # Try to extract year from journal first
    if citation.journal&.publication_date
      pub_date = citation.journal.publication_date
      # Handle if publication_date is a Date/DateTime object
      return pub_date.year.to_s if pub_date.respond_to?(:year)
      # Handle if publication_date is a string - try to parse it
      parsed_date = Date.parse(pub_date.to_s) rescue nil
      return parsed_date.year.to_s if parsed_date
    end

    # Fall back to parsing from citation name or other fields
    # Look for 4-digit year pattern
    text = [citation.name, citation.abstract].compact.join(' ')
    match = text.match(/\b(19|20)\d{2}\b/)
    match ? match[0] : nil
  end
end
