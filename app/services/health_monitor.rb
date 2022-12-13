class HealthMonitor
  ALL_TABLES = [
    Admin,
    Approval,
    Assignment,
    Author,
    AuthorsCitation,
    Citation,
    CitationsProject,
    CitationsTask,
    ComparableElement,
    Comparate,
    ComparateGroup,
    Comparison,
    ComparisonsArmsRssm,
    ComparisonsResultStatisticSection,
    Degree,
    DegreesProfile,
    Dependency,
    Dispatch,
    Extraction,
    ExtractionForm,
    ExtractionFormsProject,
    ExtractionFormsProjectType,
    ExtractionFormsProjectsSection,
    ExtractionFormsProjectsSectionOption,
    ExtractionFormsProjectsSectionType,
    ExtractionFormsProjectsSectionsType1,
    ExtractionFormsProjectsSectionsType1sTimepointName,
    ExtractionsExtractionFormsProjectsSection,
    ExtractionsExtractionFormsProjectsSectionsFollowupField,
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField,
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption,
    ExtractionsExtractionFormsProjectsSectionsType1,
    ExtractionsExtractionFormsProjectsSectionsType1Row,
    ExtractionsExtractionFormsProjectsSectionsType1RowColumn,
    FollowupField,
    Frequency,
    KeyQuestion,
    KeyQuestionsProject,
    KeyQuestionsProjectsQuestion,
    Keyword,
    Label,
    LabelsReason,
    Measure,
    Message,
    MessageType,
    Note,
    Ordering,
    Organization,
    PopulationName,
    Profile,
    Project,
    ProjectsUser,
    ProjectsUsersRole,
    ProjectsUsersTermGroupsColor,
    ProjectsUsersTermGroupsColorsTerm,
    Publishing,
    QualityDimensionOption,
    QualityDimensionQuestion,
    QualityDimensionQuestionsQualityDimensionOption,
    QualityDimensionSection,
    QualityDimensionSectionGroup,
    Question,
    QuestionRow,
    QuestionRowColumn,
    QuestionRowColumnField,
    QuestionRowColumnOption,
    QuestionRowColumnType,
    QuestionRowColumnsQuestionRowColumnOption,
    Reason,
    Record,
    ResultStatisticSection,
    ResultStatisticSectionType,
    ResultStatisticSectionTypesMeasure,
    ResultStatisticSectionsMeasure,
    Role,
    Section,
    Suggestion,
    Tag,
    Tagging,
    Task,
    TimepointName,
    TpsArmsRssm,
    TpsComparisonsRssm,
    Type1,
    User,
    WacsBacsRssm
  ].freeze

  CRITICAL_TABLES_AND_COUNT = {
    ExtractionForm => 3,
    ExtractionFormsProjectType => 3,
    ExtractionFormsProjectsSectionType => 4,
    Frequency => 4,
    QuestionRowColumnOption => 8,
    QuestionRowColumnType => 9,
    ResultStatisticSectionType => 8,
    Role => 4
  }

  def self.perform_check
    cached_anomalies = anomalies
    cached_critical_table_count_differences = critical_table_count_differences
    unless cached_anomalies == {} && cached_critical_table_count_differences == {}
      HealthMonitorMailer.report_findings(anomalies, critical_table_count_differences).deliver_now
    end
    save_counts(current_counts)
  end

  def self.before_counts
    JSON.parse(Redis.new.get('HEALTH_MONITOR') || 'null') || {}
  end

  def self.current_counts
    table_counts = {}
    ALL_TABLES.each do |table|
      count = table.count
      table_counts[table.name] = count
    end
    table_counts
  end

  def self.save_counts(table_counts)
    Redis.new.setex('HEALTH_MONITOR', 60 * 60, table_counts.to_json)
  end

  def self.anomalies
    cached_current_counts = current_counts
    anomalies = {}
    before_counts.each do |table, before_count|
      current_count = cached_current_counts[table]
      next if current_count >= before_count

      anomalies[table] = { 'before' => before_count, 'current' => current_count }
    end
    anomalies
  end

  def self.critical_table_count_differences
    cached_current_counts = current_counts
    unhealthy_tables = {}
    CRITICAL_TABLES_AND_COUNT.each do |table, normal_count|
      current_count = cached_current_counts[table.name]
      next if current_count == normal_count

      unhealthy_tables[table.name] = { 'normal' => normal_count, 'current' => current_count }
    end
    unhealthy_tables
  end
end
