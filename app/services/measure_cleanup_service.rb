class MeasureCleanupService
  def self.deduplicate_all
    trim_measures
    deduplicate_suggestion
    deduplicate_related_class(ResultStatisticSectionsMeasure)
    deduplicate_related_class(ResultStatisticSectionTypesMeasure)
    deduplicate_related_class(ComparisonsMeasure)
    deduplicate_measures
  end

  def self.trim_measures
    # Perform trimming operation in batches
    Measure.find_each(batch_size: 1000) do |measure|
      trimmed_name = measure.name.strip

      # Only update if there's a change (this prevents unnecessary writes)
      if measure.name != trimmed_name
        measure.update(name: trimmed_name)
      end
    end
  end

  def self.deduplicate_suggestion
    lookup = {}
    original_measures = Measure.group(:name).having('count(*) > 1')
    original_measures.each do |original_measure|
      debugger if lookup[original_measure.name].present?
      lookup[original_measure.name] = original_measure.id
    end

    duplicate_measures = Measure.where(name: original_measures.map(&:name)) - original_measures
    Suggestion.where(suggestable: duplicate_measures).group(:suggestable_id).each do |suggestion|
      lookup_suggestable_id = lookup[suggestion.suggestable.name]
      debugger if lookup_suggestable_id.nil?
      Suggestion.where(
        suggestable_type: 'Measure',
        suggestable_id: suggestion.suggestable_id
      ).update_all(suggestable_id: lookup_suggestable_id)
    end
  end

  def self.deduplicate_related_class(related_class)
    lookup = {}
    original_measures = Measure.group(:name).having('count(*) > 1')
    original_measures.each do |original_measure|
      debugger if lookup[original_measure.name].present?
      lookup[original_measure.name] = original_measure.id
    end

    duplicate_measures = Measure.where(name: original_measures.map(&:name)) - original_measures
    related_class.where(measure: duplicate_measures).group(:measure_id).each do |related_record|
      lookup_measure_id = lookup[related_record.measure.name]
      debugger if lookup_measure_id.nil?
      related_class
        .where(measure_id: related_record.measure_id)
        .update_all(measure_id: lookup_measure_id)
    end
  end

  def self.deduplicate_measures
    deletable_ids = Measure
                    .group(:name)
                    .having('count(*) > 1').map do |measure|
      first_measure = Measure.where(name: measure.name).order(id: :asc).first
      Measure.select(:id).where(name: first_measure.name).where.not(id: first_measure.id).pluck(:id)
    end.flatten

    begin
      raise 'Suggestion' unless Suggestion.where(suggestable_type: 'Measure').where(suggestable_id: deletable_ids).empty?
      raise 'RSSM' unless ResultStatisticSectionsMeasure.where(measure_id: deletable_ids).empty?
      raise 'RSSTM' unless ResultStatisticSectionTypesMeasure.where(measure_id: deletable_ids).empty?
      raise 'CM' unless ComparisonsMeasure.where(measure_id: deletable_ids).empty?
    rescue => e
      debugger
      raise e  
    end

    Measure.where(id: deletable_ids).delete_all
  end
end
