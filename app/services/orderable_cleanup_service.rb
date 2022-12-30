class OrderableCleanupService
  ORDERABLE_CLASSES = [
    AuthorsCitation,
    ExtractionFormsProjectsSection,
    ExtractionFormsProjectsSectionsType1,
    ExtractionsExtractionFormsProjectsSectionsType1,
    KeyQuestionsProject,
    Question,
    ResultStatisticSectionsMeasure,
    SdAnalyticFramework,
    SdEvidenceTable,
    SdGreyLiteratureSearch,
    SdJournalArticleUrl,
    SdKeyQuestion,
    SdNarrativeResult,
    SdOtherItem,
    SdPairwiseMetaAnalyticResult,
    SdPicod,
    SdPrismaFlow,
    SdResultItem,
    SdSearchStrategy,
    SdSummaryOfEvidence
  ]

  def self.perform_check
    cached_mocs = missing_ordering_counts
    if cached_mocs.values.any?(&:positive?)
      HealthMonitorMailer.report_findings('missing_ordering_counts',
                                          cached_mocs).deliver_now
    end
    cached_oocs = orphan_ordering_counts
    if cached_oocs.values.any?(&:positive?)
      HealthMonitorMailer.report_findings('orphan_ordering_counts',
                                          cached_oocs).deliver_now
    end
  end

  def self.cleanup!
    fix_missing_orderings
    delete_orphan_orderings!
  end

  def self.missing_ordering_counts
    counts = {}
    ORDERABLE_CLASSES.each do |orderable_class|
      counts[orderable_class.to_s] = orderable_class.left_joins(:ordering).where(ordering: { id: nil }).count
    end
    counts
  end

  def self.fix_missing_orderings
    AuthorsCitation.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (AuthorsCitation.where(citation: record.citation).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    ExtractionFormsProjectsSection.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (ExtractionFormsProjectsSection.where(extraction_forms_project: record.extraction_forms_project).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    ExtractionFormsProjectsSectionsType1.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (ExtractionFormsProjectsSectionsType1.where(extraction_forms_projects_section: record.extraction_forms_projects_section).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    ExtractionsExtractionFormsProjectsSectionsType1.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (ExtractionsExtractionFormsProjectsSectionsType1.where(extractions_extraction_forms_projects_section: record.extractions_extraction_forms_projects_section).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    KeyQuestionsProject.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (KeyQuestionsProject.where(extraction_forms_projects_section: record.extraction_forms_projects_section).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    Question.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (Question.where(extraction_forms_projects_section: record.extraction_forms_projects_section).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    ResultStatisticSectionsMeasure.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (ResultStatisticSectionsMeasure.where(result_statistic_section: record.result_statistic_section).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdAnalyticFramework.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdAnalyticFramework.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdEvidenceTable.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdEvidenceTable.where(sd_result_item: record.sd_result_item).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdGreyLiteratureSearch.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdGreyLiteratureSearch.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdJournalArticleUrl.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdJournalArticleUrl.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdKeyQuestion.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdKeyQuestion.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdNarrativeResult.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdNarrativeResult.where(sd_result_item: record.sd_result_item).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdOtherItem.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdOtherItem.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdPairwiseMetaAnalyticResult.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdPairwiseMetaAnalyticResult.where(sd_result_item: record.sd_result_item).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdPicod.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdPicod.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdPrismaFlow.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdPrismaFlow.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdResultItem.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdResultItem.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdSearchStrategy.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdSearchStrategy.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end

    SdSummaryOfEvidence.left_joins(:ordering).where(ordering: { id: nil }).each do |record|
      next_max_position = (SdSummaryOfEvidence.where(sd_meta_datum: record.sd_meta_datum).joins(:ordering).maximum('orderings.position') || 0) + 1
      Ordering.create!(orderable: record, position: next_max_position)
    end
  end

  def self.orphan_ordering_counts
    counts = {}
    ORDERABLE_CLASSES.each do |orderable_class|
      raw_sql = "
        SELECT COUNT(*)
        FROM `orderings`
        LEFT OUTER JOIN `#{orderable_class.table_name}`
        ON `orderings`.`orderable_id` = `#{orderable_class.table_name}`.`id`
        WHERE `#{orderable_class.table_name}`.`id` IS NULL
        AND `orderings`.`orderable_type` = '#{orderable_class}'
      "
      counts[orderable_class.to_s] = ActiveRecord::Base.connection.execute(raw_sql).first.first
    end
    counts
  end

  def self.delete_orphan_orderings!
    deleted_ids = []
    ORDERABLE_CLASSES.each do |orderable_class|
      raw_sql = "
        SELECT `orderings`.`id`
        FROM `orderings`
        LEFT OUTER JOIN `#{orderable_class.table_name}`
        ON `orderings`.`orderable_id` = `#{orderable_class.table_name}`.`id`
        WHERE `#{orderable_class.table_name}`.`id` IS NULL
        AND `orderings`.`orderable_type` = '#{orderable_class}'
      "
      ActiveRecord::Base.connection.exec_query(raw_sql).each do |result|
        deleted_ids << result['id']
      end
    end
    Ordering.where(id: deleted_ids).delete_all
    deleted_ids
  end
end
