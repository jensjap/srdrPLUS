require 'mysql2'

def db_recovery
  @db_recovery ||= Mysql2::Client.new(Rails.configuration.database_configuration['recovery'])
end

def logger
  @logger ||= Logger.new($stdout)
  @logger.level = 'info'
  @logger
end

def initialize_recovery_variables
  raise 'Missing ENV value for `recover_question_option_project_id`' if ENV['recover_question_option_project_id'].blank?
  raise 'Missing ENV value for `SRDRPLUS_DATABASE_RECOVERY_SCHEMA`' if ENV['SRDRPLUS_DATABASE_RECOVERY_SCHEMA'].blank?

  @project_id         = ENV['recover_question_option_project_id']
  @recovery_project_q = db_recovery.query(
    "SELECT
    *
    FROM
    projects
    WHERE id=#{@project_id}"
  )
  @project       = Project.find(@project_id)
  @cnt_restores  = 0
  @cnt_recreated = 0
end

def main
  logger.info "Working on the following project id: #{@project_id}"
  logger.info "Found project with title: #{@recovery_project_q.pluck('name')}"
  logger.info "Project object: #{@recovery_project_q.entries.first}"
  _get_all_multi_choice_qrc_in_project.each do |qrc|
    _recover_options_for_multi_choice_qrc(qrc)
  end
  logger.info ''
  logger.info '////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
  logger.info " Number of restored options : #{@cnt_restores}"
  logger.info " Number of recreated options: #{@cnt_recreated}"
  logger.info '////////////////////////\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\'
end

def _get_all_multi_choice_qrc_in_project
  arr_multi_choice_qrc = []
  @project.extraction_forms_projects.first.extraction_forms_projects_sections.each do |efps|
    efps.questions.each do |question|
      arr_multi_choice_qrc.concat question.question_row_columns.where(question_row_column_type: [5, 6, 7, 8, 9])
    end
  end
  arr_multi_choice_qrc.each do |qrc|
    logger.debug "Found qrc with type #{qrc.question_row_column_type.name}"
  end
  logger.debug "Total qrc found: #{arr_multi_choice_qrc.size}"
  arr_multi_choice_qrc
end

def _recover_options_for_multi_choice_qrc(qrc)
  recovery_qrcqrco_q = db_recovery.query(
    "SELECT
    *
    FROM
    question_row_columns_question_row_column_options
    WHERE question_row_column_id=#{qrc.id}
    AND
    question_row_column_option_id=1
    AND
    deleted_at is NULL"
  )
  recovery_qrcqrco_q.each do |qrcqrco_q|
    pid     = qrcqrco_q['id'].to_i
    qrc_id  = qrcqrco_q['question_row_column_id'].to_i
    qrco_id = qrcqrco_q['question_row_column_option_id'].to_i
    name    = qrcqrco_q['name']

    qrcqrco = _find_qrcqrco(qrc_id, qrco_id, name)
    if qrcqrco.present?
      # If qrcqrco is found then check whether the primary id matches.
      if qrcqrco.id.eql?(pid)
        # Nothing to do, this option is present.
        logger.debug 'Options already present:'
        logger.debug "  Question: '#{qrcqrco.question.name}'"
        logger.debug "  #{qrcqrco.name}"
      else
        # Don't do anything, just report this.
        logger.debug '????????????????????????????????????????????????????????????????????'
        logger.debug 'FOUND QRCQRCO WITH MATCHING QRC.ID, QRCO.ID AND NAME BUT ID DIFFERS.'
        logger.debug 'Maybe someone added it back in already.'
        logger.debug "Question: '#{qrc.question.name}'"
        logger.debug "  id     : #{pid}"
        logger.debug "  qrc_id : #{qrc_id}"
        logger.debug "  qrco_id: #{qrco_id}"
        logger.debug "  name   : #{name}"
        logger.debug '????????????????????????????????????????????????????????????????????'
      end
    else
      # Since no qrcqrco is found, we create missing option.
      logger.info '|=====================================|'
      logger.info "Question: \"#{qrc.question.name}\""
      logger.info "  Recovery DB option: \"#{name}\""
      logger.info '  Failed to find option in current db.'
      logger.info '  Creating option.'
      _create_qrcqrco_with_primary_id_and_option_text(pid, qrc_id, qrco_id, name)
    end
  end
end

def _find_qrcqrco(question_row_column_id, question_row_column_option_id, name)
  QuestionRowColumnsQuestionRowColumnOption
    .find_by(
      question_row_column_id:,
      question_row_column_option_id:,
      name:
    )
end

def _create_qrcqrco_with_primary_id_and_option_text(id, question_row_column_id, question_row_column_option_id, name)
  begin
    # Try to create one with the original ID.
    qrcqrco = QuestionRowColumnsQuestionRowColumnOption.new(
      id:,
      question_row_column_id:,
      name:,
      question_row_column_option_id: 1
    )
    qrcqrco.save
    logger.info 'Successfully created QuestionRowColumnsQuestionRowColumnOption with original ID.'
  rescue StandardError => e
    logger.info 'Unable to create QuestionRowColumnsQuestionRowColumnOption with original ID.'
    qrcqrco = QuestionRowColumnsQuestionRowColumnOption.new(
      question_row_column_id:,
      name:,
      question_row_column_option_id: 1
    )
    qrcqrco.save
    logger.info 'Created one with new ID.'
  end
  @cnt_recreated += 1
  logger.info 'Created missing option: '
  logger.info "  id     : #{id}"
  logger.info "  qrc_id : #{question_row_column_id}"
  logger.info "  qrco_id: #{question_row_column_option_id}"
  logger.info "  name   : #{name}"
  logger.info '|=====================================|'
  logger.info '|                Success              |'
  logger.info '|=====================================|'
end

namespace(:recover_question_options) do
  desc 'Recover deleted question options from old db_recovery snapshot.'
  task project: :environment do
    initialize_recovery_variables
    main
  end
end
