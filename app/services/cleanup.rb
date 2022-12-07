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
    ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnFieldsQuestionRowColumnsQuestionRowColumnOption,
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
    QualityDimensionSectionGroup,
    QualityDimensionSection,
    QuestionRowColumnField,
    QuestionRowColumnOption,
    QuestionRowColumnType,dedupe_eefpsff
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
    ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=0;')
    restore_efps_sql = "
      UPDATE `extraction_forms_projects_sections`
      SET `extraction_forms_projects_sections`.`active` = TRUE, `extraction_forms_projects_sections`.`deleted_at` = NULL
      WHERE `extraction_forms_projects_sections`.`section_id` IN (
        SELECT `sections`.`id`
        FROM `sections`
        WHERE (sections.name IN (
          'Diagnostic Tests','Diagnostic Test Details','Diagnoses','Diagnosis Details','Arms','Arm Details','Outcomes','Outcome Details'
        ))
      );
    "
    ActiveRecord::Base.connection.execute(restore_efps_sql)
    RELEVANT_CLASSES.each do |rc|
      table_name = rc.table_name
      sql = "DELETE FROM `#{table_name}` WHERE `#{table_name}`.`deleted_at` IS NOT NULL"
      ActiveRecord::Base.connection.execute(sql)
    end
  ensure
    ActiveRecord::Base.connection.execute('SET FOREIGN_KEY_CHECKS=1;')
  end

  def self.deleted_count
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    total = 0
    messages = []
    RELEVANT_CLASSES.each do |rc|
      count = rc.where.not(deleted_at: nil).count
      whitespace_count = 150 - rc.to_s.length - count.to_s.length
      messages << "#{rc}:#{' ' * whitespace_count}#{count}"
      total += count
    end
    puts messages
    puts "Total:#{' ' * (150 - 5 - total.to_s.length)}#{total}"
    ActiveRecord::Base.logger = old_logger
  end

  def self.regular_count
    old_logger = ActiveRecord::Base.logger
    ActiveRecord::Base.logger = nil
    total = 0
    messages = []
    RELEVANT_CLASSES.each do |rc|
      count = rc.count
      whitespace_count = 150 - rc.to_s.length - count.to_s.length
      messages << "#{rc}:#{' ' * whitespace_count}#{count}"
      total += count
    end
    puts messages
    puts "Total:#{' ' * (150 - 5 - total.to_s.length)}#{total}"
    ActiveRecord::Base.logger = old_logger
  end

  def self.dedupe_all
    dedupe_statusing
    dedupe_eefpsff
  end

  def self.dedupe_statusing
    grouped = Statusing.all.group_by { |model| [model.statusable_type, model.statusable_id, model.status_id] }
    number_of_destroyed = 0
    grouped.each_value do |duplicates|
      duplicates.sort_by!(&:id)
      duplicates.shift
      duplicates.each.each do |duplicate|
        number_of_destroyed += 1 if duplicate.destroy
      end
    end
    number_of_destroyed
  end

  def self.dedupe_eefpsff
    grouped = ExtractionsExtractionFormsProjectsSectionsFollowupField.all.group_by do |model|
      [
        model.extractions_extraction_forms_projects_section_id,
        model.extractions_extraction_forms_projects_sections_type1_id,
        model.followup_field_id
      ]
    end
    number_of_destroyed = 0
    grouped.each_value do |duplicates|
      duplicates.sort_by!(&:id)
      duplicates.shift
      duplicates.each.each do |duplicate|
        number_of_destroyed += 1 if duplicate.destroy
      end
    end
    number_of_destroyed
  end
end
