require 'mysql2'

def db
  @db ||= Mysql2::Client.new(Rails.configuration.database_configuration['recovery'])
end

namespace(:db) do
  namespace(:recover_question_options) do
    desc 'Recover deleted question options from old db snapshot.'
    task project: :environment do
      initialize_variables
      main
    end  # task :project, [] => :environment do |task, args|

    def initialize_variables
      @logger             = Logger.new($stdout)
      @logger.level       = 'info'
      @project_id         = ENV['recover_question_option_project_id']
      @recovery_project_q = db.query(
        "SELECT
        *
        FROM
        projects
        WHERE id=#{@project_id}"
      )
      @project = Project.find(@project_id)
    end  # def initialize_variables

    def main
      @logger.info "Working on the following project id: #{@project_id}"
      @logger.info "Found project with title: #{@recovery_project_q.pluck('name')}"
      @logger.info "Project object: #{@recovery_project_q.entries.first}"

      _get_all_multi_choice_qrc_in_project.each do |qrc|
        _recover_options_for_multi_choice_qrc(qrc)
      end  # _get_all_multi_choice_qrc_in_project.each do |qrc|
    end  # def main

    def _get_all_multi_choice_qrc_in_project
      arr_multi_choice_qrc = []
      efp = @project.extraction_forms_projects.first
      efp.extraction_forms_projects_sections.each do |efps|
        efps.questions.each do |question|
          arr_multi_choice_qrc.concat question
            .question_row_columns
            .where(question_row_column_type: [5, 6, 7, 8, 9])
        end  # efps.questions.each do |question|
      end  # efp.extraction_forms_projects_sections.each do |efps|

      arr_multi_choice_qrc.each do |qrc|
        @logger.info "Found qrc with type #{qrc.question_row_column_type.name}"
      end  # arr_multi_choice_qrc.each do |qrc|
      @logger.info "Total qrc found: #{arr_multi_choice_qrc.size}"

      arr_multi_choice_qrc
    end  # def _get_all_multi_choice_qrc_in_project()

    def _recover_options_for_multi_choice_qrc(qrc)
      recovery_qrcqrco_q = db.query(
        "SELECT
        *
        FROM
        question_row_columns_question_row_column_options
        WHERE question_row_column_id=#{qrc.id}
        AND
        question_row_column_option_id=1"
      )
      recovery_qrcqrco_q.each do |qrcqrco_q|
        pid  = qrcqrco_q['id'].to_i
        name = qrcqrco_q['name']
        begin
          qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find(qrcqrco_q['id'])
        rescue ActiveRecord::RecordNotFound => e
          @logger.info "Question: \"#{qrc.question.name}\""
          @logger.info "  Recovery DB option: \"#{name}\""
          @logger.info '  Failed to find option'
        end
      end  # recovery_qrcqrco_q.each do |qrcqrco|
    end  # def _recover_options_for_multi_choice_qrc(qrc)

    def _create_qrcqrco_with_primary_id_and_option_text(id, name)
      @logger.info "#{id}"
      @logger.info "#{name}"
    end  # def _create_qrcqrco_with_primary_id_and_option_text(id, name)
  end  # namespace(:recover_question_options) do
end  # namespace(:db) do