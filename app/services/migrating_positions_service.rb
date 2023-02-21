class MigratingPositionsService
  ORDERABLE_TABLES = [
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
    SdKeyQuestionsSdPicod,
    SdMetaRegressionAnalysisResult,
    SdNarrativeResult,
    SdNetworkMetaAnalysisResult,
    SdOtherItem,
    SdPairwiseMetaAnalyticResult,
    SdPicod,
    SdPrismaFlow,
    SdResultItem,
    SdSearchStrategy,
    SdSummaryOfEvidence
  ]

  def self.migrate_positions!
    time do
      ORDERABLE_TABLES.each do |table|
        table.left_joins(:ordering).includes(:ordering).where(ordering: { orderable_type: table }).find_in_batches do |table_group|
          orderable_objects = []
          table_group.each do |table_item|
            duplicate = table_item.as_json
            duplicate['position'] = table_item&.ordering&.position || 0
            orderable_objects << duplicate
          end
          table.upsert_all(orderable_objects, update_only: [:position])
        end
      end
    end
  end

  def self.migrate_positions_check
    time do
      correct = 0
      incorrect = 0
      ORDERABLE_TABLES.each do |table|
        table.left_joins(:ordering).includes(:ordering).where(ordering: { orderable_type: table }).find_in_batches do |table_group|
          table_group.each do |table_item|
            if table_item.position == table_item.ordering.position
              correct += 1
            else
              incorrect += 1
            end
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
