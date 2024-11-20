class MeasureCleanupService
  def self.deduplicate_all
    deduplicate_suggestion
    deduplicate_related_class(ResultStatisticSectionsMeasure)
    deduplicate_related_class(ResultStatisticSectionTypesMeasure)
    deduplicate_related_class(ComparisonsMeasure)
    deduplicate_measures
  end

  def self.deduplicate_suggestion
    lookup = {}
    original_measures = Measure.group(:name).having('count(*) > 1')
    original_measures.each do |original_measure|
      lookup[original_measure.name] = original_measure.id
    end

    duplicate_measures = Measure.where(name: original_measures.map(&:name)) - original_measures
    Suggestion.where(suggestable: duplicate_measures).group(:suggestable_id).each do |suggestion|
      Suggestion.where(
        suggestable_type: 'Measure',
        suggestable_id: suggestion.suggestable_id
      ).update_all(suggestable_id: lookup[suggestion.suggestable.name])
    end
  end

  def self.deduplicate_related_class(related_class)
    lookup = {}
    original_measures = Measure.group(:name).having('count(*) > 1')
    original_measures.each do |original_measure|
      lookup[original_measure.name] = original_measure.id
    end

    duplicate_measures = Measure.where(name: original_measures.map(&:name)) - original_measures
    related_class.where(measure: duplicate_measures).group(:measure_id).each do |related_record|
      related_class
        .where(measure_id: related_record.measure_id)
        .update_all(measure_id: lookup[related_record.measure.name])
    end
  end

  def self.deduplicate_measures
    deletable_ids = Measure
                    .group(:name)
                    .having('count(*) > 1').map do |measure|
      first_measure = Measure.where(name: measure.name).order(id: :asc).first
      Measure.select(:id).where(name: first_measure.name).where.not(id: first_measure.id).pluck(:id)
    end.flatten

    raise 'Suggestion' unless Suggestion.where(suggestable_type: 'Measure').where(suggestable_id: deletable_ids).empty?
    raise 'RSSM' unless ResultStatisticSectionsMeasure.where(measure_id: deletable_ids).empty?
    raise 'RSSTM' unless ResultStatisticSectionTypesMeasure.where(measure_id: deletable_ids).empty?
    raise 'CM' unless ComparisonsMeasure.where(measure_id: deletable_ids).empty?

    Measure.where(id: deletable_ids).delete_all
  end
end
