class Cleanup
  RELEVANT_CLASSES = [
    Approval,
    Assignment,
    Author,
    AuthorsCitation,
    Citation,
    CitationsProject,
    CitationsTask,
    ComparableElement,
    ComparateGroup,
    Comparate,
    Comparison,
    ComparisonsArmsRssm,
    ComparisonsResultStatisticSection,
    Degree,
    DegreesProfile,
    Dependency,
    Dispatch,
    ExtractionForm,
    ExtractionFormsProjectType,
    ExtractionFormsProject,
    ExtractionFormsProjectsSectionOption,
    ExtractionFormsProjectsSectionType,
    ExtractionFormsProjectsSection,
    ExtractionFormsProjectsSectionsType1,
    ExtractionFormsProjectsSectionsType1sTimepointName,
    Extraction,
    ExtractionsExtractionFormsProjectsSection,
    ExtractionsExtractionFormsProjectsSectionsFollowupField,
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField,
    ExtractionsExtractionFormsProjectsSectionsType1RowColumn,
    ExtractionsExtractionFormsProjectsSectionsType1Row,
    ExtractionsExtractionFormsProjectsSectionsType1,
    # ExtractionsKeyQuestionsProject, # missing from DB
    ExtractionsProjectsUsersRole,
    FollowupField,
    Frequency,
    KeyQuestion,
    KeyQuestionsProject,
    KeyQuestionsProjectsQuestion,
    Keyword,
    Label,
    LabelsReason,
    Measure,
    MessageType,
    Message,
    Note,
    Ordering, # use raw sql delete
    Organization,
    PopulationName,
    Profile,
    Project,
    ProjectsStudy,
    ProjectsUser,
    ProjectsUsersRole,
    ProjectsUsersTermGroupsColor,
    ProjectsUsersTermGroupsColorsTerm,
    Publishing,
    QualityDimensionOption,
    QualityDimensionQuestion,
    QualityDimensionQuestionsQualityDimensionOption,
    QualityDimensionSectionGroup,
    QualityDimensionSection,
    QuestionRowColumnField,
    QuestionRowColumnOption,
    QuestionRowColumnType,
    QuestionRowColumn,
    QuestionRowColumnsQuestionRowColumnOption,
    QuestionRow,
    Question,
    Reason,
    Record,
    ResultStatisticSectionType,
    ResultStatisticSectionTypesMeasure,
    ResultStatisticSection,
    ResultStatisticSectionsMeasure,
    Role,
    Section,
    Study,
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
  ]

  def self.really_destroy_all!
    raw_sql_delete_classes_without_callbacks_or_dependencies
    RELEVANT_CLASSES.each do |rc|
      rc.only_deleted.each(&:really_destroy!)
    end
  end

  def self.count
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    total = 0
    messages = []
    RELEVANT_CLASSES.each do |rc|
      count = rc.only_deleted.count
      whitespace_count = 80 - rc.to_s.length - count.to_s.length
      messages << "#{rc}:#{' ' * whitespace_count}#{count}"
      total += count
    end
    puts messages
    puts "Total:#{' ' * (80 - 5 - total.to_s.length)}#{total}"
    ActiveRecord::Base.logger = old_logger
  end

  def self.raw_sql_delete_classes_without_callbacks_or_dependencies
    raw_sql_delete_orderings
  end

  def self.raw_sql_delete_orderings
    sql = "DELETE FROM `orderings` WHERE (`orderings`.`active` IS NULL OR `orderings`.`active` != '1')"
    ActiveRecord::Base.connection.execute(sql)
  end
end
