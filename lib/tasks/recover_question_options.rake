require 'mysql2'

def db
  @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['recovery'])
end

namespace(:db) do
  namespace(:recover_question_options) do
    desc "Recover deleted question options from old db snapshot."
    task :project => :environment do
      initialize_variables()
      main()
    end  # task :project, [] => :environment do |task, args|

    def initialize_variables()
      @project_id = ENV['recover_question_option_project_id']
      @project_q = db.query("SELECT * FROM projects WHERE id=#{@project_id}")
    end  # def initialize_variables()

    def main()
      logger = Logger.new(STDOUT)
      logger.info "Working on the following project id: #{@project_id}"
      logger.info "Found project with title: #{@project_q.pluck("name")}"
      logger.info "Project object: #{@project_q.entries.first}"

      #_get_all_multi_choice_questions_in_project()
      #_get_options_for_multi_choice_questions()
      #_compare_choices_for_the_same_question_id_in_current_db()
      #_display_differences()
      #_add_them_back_in()
    end  # def main()
  end  # namespace(:recover_question_options) do
end  # namespace(:db) do