class OrderableCleanupService
  ORDERABLE_CLASSES = [
    ExtractionFormsProjectsSection,
    ExtractionFormsProjectsSectionsType1,
    ExtractionsExtractionFormsProjectsSectionsType1,
    KeyQuestionsProject,
    Question
  ]
  #  ResultStatisticSectionsMeasure,
  #  SdAnalyticFramework,
  #  SdEvidenceTable,
  #  SdGreyLiteratureSearch,
  #  SdJournalArticleUrl,
  #  SdKeyQuestion,
  #  SdNarrativeResult,
  #  SdOtherItem,
  #  SdPairwiseMetaAnalyticResult,
  #  SdPicod,
  #  SdPrismaFlow,
  #  SdResultItem,
  #  SdSearchStrategy,
  #  SdSummaryOfEvidence
  #]

  def self.get_counts!
    ap childless_ordering_counts
    ap orphan_ordering_counts
  end

  def self.cleanup!
    delete_orphan_orderings!
    delete_childless_parents!
  end

  def self.childless_ordering_counts
    counts = {}
    ORDERABLE_CLASSES.each do |orderable_class|
      raw_sql = "
        SELECT COUNT(*)
        FROM `#{orderable_class.table_name}`
        LEFT OUTER JOIN `orderings`
        ON `orderings`.`orderable_type` = '#{orderable_class}'
        AND `orderings`.`orderable_id` = `#{orderable_class.table_name}`.`id`
        WHERE `orderings`.`id` IS NULL
      "
      counts[orderable_class.to_s] = ActiveRecord::Base.connection.execute(raw_sql).first.first
    end
    counts
  end

  def self.delete_childless_parents!
    ActiveRecord::Base.connection.exec_query("SET foreign_key_checks = 0;")
    deleted = {}
    ORDERABLE_CLASSES.each do |orderable_class|
      deleted_ids = []
      raw_sql = "
        SELECT `#{orderable_class.table_name}`.`id`
        FROM `#{orderable_class.table_name}`
        LEFT OUTER JOIN `orderings`
        ON `orderings`.`orderable_type` = '#{orderable_class}'
        AND `orderings`.`orderable_id` = `#{orderable_class.table_name}`.`id`
        WHERE `orderings`.`id` IS NULL
      "
      ActiveRecord::Base.connection.exec_query(raw_sql).each do |result|
        deleted_ids << result['id']
      end
      if deleted_ids.present?
        ActiveRecord::Base.connection.exec_query("DELETE from `#{orderable_class.table_name}` WHERE `id` IN (#{deleted_ids.join(', ')});")
      end
      deleted[orderable_class.table_name] = deleted_ids
    end
    deleted
    ActiveRecord::Base.connection.exec_query("SET foreign_key_checks = 1;")
  end

  def self.orphan_ordering_counts
    counts = {}
    ORDERABLE_CLASSES.each do |orderable_class|
      raw_sql = "
        SELECT COUNT(*)
        FROM `orderings`
        LEFT OUTER JOIN `#{orderable_class.table_name}`
        ON `orderings`.`orderable_id` = `#{orderable_class.table_name}`.`id`
        WHERE `orderings`.`orderable_type` = '#{orderable_class}'
        AND `#{orderable_class.table_name}`.`id` IS NULL
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
        WHERE `orderings`.`orderable_type` = '#{orderable_class}'
        AND `#{orderable_class.table_name}`.`id` IS NULL
      "
      ActiveRecord::Base.connection.exec_query(raw_sql).each do |result|
        deleted_ids << result['id']
      end
    end
    if deleted_ids.present?
      ActiveRecord::Base.connection.exec_query("DELETE from `orderings` WHERE `id` IN (#{deleted_ids.join(', ')});")
    end
    deleted_ids
  end
end
