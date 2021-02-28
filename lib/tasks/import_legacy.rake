require 'mysql2'

def db
  @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['legacy_production'])
end

namespace(:db) do
  namespace(:import_legacy) do
    desc "import legacy projects"
    task :projects => :environment do 
      initialize_variables

      if ENV['pids'].present?
        pids = ENV['pids'].split(",").map{|x| x.to_i}
      else
        projects = db.query("SELECT * FROM projects")
        pids = projects.pluck("id").map{|x| x.to_i}
      end

      if ENV['max_pid'].present?
        max_pid = ENV['max_pid'].to_i
        pids = pids.select{|x| max_pid >= x}
      end

      if ENV['min_pid'].present?
        min_pid = ENV['min_pid'].to_i
        pids = pids.select{|x| x >= min_pid}
      end

      projects = db.query("SELECT * FROM projects WHERE id in (#{pids.join(',')})")

      projects.each do |project_hash|
        begin
          @legacy_project_id = project_hash["id"]
          reset_project_variables
          migrate_legacy_srdr_project project_hash
          p "Source Project:"
          ap project_hash
          p "Target Project"
          ap get_srdrplus_project(@legacy_project_id)
        rescue => error
          puts error
          puts error.backtrace
          Rails.logger.debug "Error with legacy SRDR project: #{@legacy_project_id}"
          Rails.logger.debug error.backtrace
          @legacy_project_id = nil
          reset_project_variables

          #TODO write problematic project source ids to file
          #TODO write problematic project target ids to file
        end
      end
    end
    
    def migration_user
      User.first.freeze
    end

    def initialize_variables
      @other_please_specify = "Other (please specify):".freeze

      @efps_type_1 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 1')
      @efps_type_2 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 2')
      @efps_type_results = ExtractionFormsProjectsSectionType.find_by(name: 'Results')
      @efps_type_4 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 4')
      @efp_type_standard = ExtractionFormsProjectType.find_by(name: 'Standard')
      @efp_type_diagnostic = ExtractionFormsProjectType.find_by(name: 'Diagnostic Test')

      @qrc_type_text = QuestionRowColumnType.find_by(name: 'text')
      @qrc_type_numeric = QuestionRowColumnType.find_by(name: 'numeric')
      @qrc_type_numeric_range = QuestionRowColumnType.find_by(name: 'numeric_range')
      @qrc_type_scientific = QuestionRowColumnType.find_by(name: 'scientific')
      @qrc_type_checkbox = QuestionRowColumnType.find_by(name: 'checkbox')
      @qrc_type_dropdown = QuestionRowColumnType.find_by(name: 'dropdown')
      @qrc_type_radio = QuestionRowColumnType.find_by(name: 'radio')
      @qrc_type_select2_single = QuestionRowColumnType.find_by(name: 'select2_single')
      @qrc_type_select2_multi = QuestionRowColumnType.find_by(name: 'select2_multi')

      @qrco_answer_choice = QuestionRowColumnOption.find_by(name: 'answer_choice')
      @qrco_min_length = QuestionRowColumnOption.find_by(name: 'min_length')
      @qrco_max_length = QuestionRowColumnOption.find_by(name: 'max_length')
      @qrco_additional_char = QuestionRowColumnOption.find_by(name: 'additional_char')
      @qrco_min_value = QuestionRowColumnOption.find_by(name: 'min_value')
      @qrco_max_value = QuestionRowColumnOption.find_by(name: 'max_value')
      @qrco_coefficient = QuestionRowColumnOption.find_by(name: 'coefficient')
      @qrco_exponent = QuestionRowColumnOption.find_by(name: 'exponent')

      @type1_types = {"Categorical" => Type1Type.find_by(name: "Categorical"),
                      "Continuous" => Type1Type.find_by(name: "Continuous"),
                      "Time to Event" => Type1Type.find_by(name: "Time to Event"),
                      1 => Type1Type.find_by(name: "Index Test"), #?????????
                      2 => Type1Type.find_by(name: "Reference Test")}#?????????

      @rss_type_descriptive = ResultStatisticSectionType.find_by(name: "Descriptive Statistics")
      @rss_type_between = ResultStatisticSectionType.find_by(name: "Between Arm Comparisons")
      @rss_type_within = ResultStatisticSectionType.find_by(name: "Within Arm Comparisons")
      @rss_type_net = ResultStatisticSectionType.find_by(name: "NET Change")
    end

    def reset_project_variables
      @srdr_to_srdrplus_project_dict = {}
      @srdr_to_srdrplus_key_questions_dict = {}
      @default_projects_users_role = nil
      @data_points_queue = {}
      @efps_dict = {}
      @eefspt1_dict = {}
      @qrcqrco_dict = {}
      @followup_dict = {qrc_to_ff: {}, qrcqrco_to_ff: {}}
      @tp_dict = {}
    end

    def set_tp tp_id, tp
      @tp_dict[tp_id] = tp
    end

    def get_tp tp_id
      @tp_dict[tp_id.to_i]
    end

    def set_followup_field qrcqrco
      @followup_dict[:qrcqrco_to_ff][qrcqrco.id] = qrcqrco.followup_field
      @followup_dict[:qrc_to_ff][qrcqrco.question_row_column.id] = qrcqrco.followup_field
    end

    def get_ff_by_qrcqrco qrcqrco_id
      @followup_dict[:qrcqrco_to_ff][qrcqrco_id]
    end

    def get_ff_by_qrc qrc_id
      @followup_dict[:qrc_to_ff][qrc_id]
    end

    def set_qrcqrco qrc_id, option_text, qrcqrco
      @qrcqrco_dict[qrc_id] ||= {}
      @qrcqrco_dict[qrc_id][option_text] = qrcqrco.id
    end

    def get_qrcqrco qrc_id, option_text
      if @qrcqrco_dict.key? qrc_id
        @qrcqrco_dict[qrc_id][option_text]
      else
        return nil
      end
    end

    def set_eefpst1 t1_name, t1_id, eefpst1
      @eefspt1_dict[t1_name] ||= {}
      @eefspt1_dict[t1_name][t1_id] = eefpst1
    end

    def get_eefpst1 t1_name, t1_id
      @eefspt1_dict[t1_name] ||= {}
      @eefspt1_dict[t1_name][t1_id.to_i]
    end

    def set_efps t1_name, efps
      @efps_dict[t1_name] = efps
    end

    def get_efps t1_name
      if @efps_dict.key? t1_name
        @efps_dict[t1_name]
      else
        byebug
      end
    end

    def queue_data_point dp, qrcf, dp_type=nil
      study_id = dp["study_id"]
      question_type = qrcf.question_row_column.question_row_column_type

      @data_points_queue[study_id] ||= {}
      @data_points_queue[study_id][qrcf.id] ||= {data_points: [], qrcf: qrcf, question_type: question_type, dp_type: dp_type}
      if not @data_points_queue[study_id][qrcf.id][:data_points].include? dp
        @data_points_queue[study_id][qrcf.id][:data_points] << dp
      end
    end
    
    def get_data_point_queue_for_study study_id
      if @data_points_queue.key? study_id
        return @data_points_queue[study_id]
      else
        return {}
      end
    end

    def get_srdrplus_project srdr_project_id
      @srdr_to_srdrplus_project_dict[srdr_project_id]
    end

    def set_srdrplus_project srdr_project_id, srdrplus_project
      @srdr_to_srdrplus_project_dict[srdr_project_id] = srdrplus_project
    end

    def set_srdrplus_key_question srdr_key_question_id, srdrplus_key_question
      @srdr_to_srdrplus_key_questions_dict[srdr_key_question_id] = srdrplus_key_question
    end

    def get_srdrplus_key_question srdr_key_question_id
      @srdr_to_srdrplus_key_questions_dict[srdr_key_question_id]
    end

    def add_default_user_to_srdrplus_project srdrplus_project
      srdrplus_project.users << migration_user
      srdrplus_project.projects_users.first.roles << Role.first

      @default_projects_users_role = srdrplus_project.projects_users.first.projects_users_roles.first
    end

    def create_srdrplus_project project_hash
      project_id = project_hash["id"]
      project_name = project_hash["title"]
      project_description = project_hash["description"]
      methodology_description = project_hash["methodology"]
      prospero = project_hash["prospero_id"]
      notes = project_hash["notes"]
      doi = project_hash["doi_id"]
      funding_source = project_hash["funding_source"]

      #TODO What to do with publications ?, is_public means published in SRDR
      srdrplus_project = Project.new name: project_name, 
                                     description: project_description,
                                     methodology_description: methodology_description,
                                     notes: notes,
                                     doi: doi,
                                     funding_source: funding_source,
                                     prospero: prospero

      srdrplus_project.save #need to save, because i want the default efp
      srdrplus_project.extraction_forms_projects.first.extraction_forms_projects_sections.destroy_all #need to delete default sections

      add_default_user_to_srdrplus_project srdrplus_project

      set_srdrplus_project project_id, srdrplus_project
    end

    def migrate_legacy_srdr_project project_hash
      # DO I WANT TO CREATE USERS? probably no
      #purs = db.query "SELECT * FROM user_project_roles where project_id=#{project_hash["id"]}"
      #purs.each do |pur|
      #  break#DELETE THIS 
      #end

      create_srdrplus_project project_hash
      migrate_key_questions

      # Extraction Forms Migration
      efs = db.query "SELECT * FROM extraction_forms where project_id=#{@legacy_project_id}"
      efp_type = get_efp_type efs

      if efp_type == false
        return
      end
      get_srdrplus_project(@legacy_project_id).extraction_forms_projects.first.update(extraction_forms_project_type: efp_type)
      migrate_extraction_forms_as_standard_efp efs
      studies_hash = db.query "SELECT * FROM studies where project_id=#{@legacy_project_id}"
      studies_hash.each do |study_hash|
        study_id = study_hash["id"]

        primary_publications = db.query "SELECT * FROM primary_publications where study_id=#{study_id}"
        primary_publications.each do |primary_publication_hash|
          citation = migrate_primary_publication_as_citation primary_publication_hash 
          citations_project = CitationsProject.create citation: citation, project: get_srdrplus_project(@legacy_project_id)
          migrate_study_as_extraction study_hash, citations_project.id
          break
        end
      end
    end

    def migrate_extraction_forms_as_standard_efp efs
      combined_efp = get_srdrplus_project(@legacy_project_id).extraction_forms_projects.first

      efs.each do |ef|
        ef_sections = db.query "SELECT * FROM extraction_form_sections where extraction_form_id=#{ef["id"]}"
        ef_key_questions = db.query "SELECT * FROM extraction_form_key_questions where extraction_form_id=#{ef["id"]}"

        t1_efps = []
        t2_efps = []

        arms_efps = nil
        outcomes_efps = nil
        adverse_events_efps = nil
        diagnostic_tests_efps = nil

        ef_sections.each do |ef_section|
          section = Section.find_or_create_by(name: ef_section["section_name"].titleize)
          case ef_section["section_name"]
          when "arms"
            arms_efps = combined_efp.extraction_forms_projects_sections.find_or_create_by(section: section, 
                                                                               extraction_forms_projects_section_type: @efps_type_1)
            set_efps "arms", arms_efps
            if adverse_events_efps.present? then adverse_events_efps.update(link_to_type1:arms_efps) end

            ef_arms = db.query "SELECT * FROM extraction_form_arms where extraction_form_id=#{ef["id"]}"
            ef_arms.each do |ef_arm|
              type1 = Type1.find_or_create_by name: ef_arm["name"], description: ef_arm["description"]
              Suggestion.find_or_create_by suggestable: type1 , user: migration_user
              ExtractionFormsProjectsSectionsType1.create extraction_forms_projects_section: arms_efps, type1: type1
            end
          when "outcomes"
            outcomes_efps = combined_efp.extraction_forms_projects_sections.find_or_create_by(section: section, 
                                                                                   extraction_forms_projects_section_type: @efps_type_1)
            set_efps "outcomes", outcomes_efps
            ef_outcomes = db.query "SELECT * FROM extraction_form_outcome_names where extraction_form_id=#{ef["id"]}"
            ef_outcomes.each do |ef_outcome|
              type1 = Type1.find_or_create_by name: ef_outcome["title"], description: ef_outcome["note"]
              Suggestion.find_or_create_by suggestable: type1 , user: migration_user
              type1_type = @type1_types[ef_outcome["outcome_type"]]
              ExtractionFormsProjectsSectionsType1.create extraction_forms_projects_section: outcomes_efps, 
                                                          type1: type1, 
                                                          type1_type: type1_type
            end
          when "diagnostics"
            diagnostic_tests_efps = combined_efp.extraction_forms_projects_sections.find_or_create_by(section: section, extraction_forms_projects_section_type: @efps_type_4)
            set_efps "diagnostic_tests", diagnostic_tests_efps
            ef_diagnostic_tests = db.query "SELECT * FROM extraction_form_outcome_names where extraction_form_id=#{ef["id"]}"
            ef_diagnostic_tests.each do |ef_diagnostic_test|
              type1 = Type1.find_or_create_by name: ef_diagnostic_test["title"], description: ef_diagnostic_test["description"]

              Suggestion.find_or_create_by suggestable: type1, user: migration_user

              type1_type = @type1_types[ef_diagnostic_test["test_type"]]
              ExtractionFormsProjectsSectionsType1.create extraction_forms_projects_section: diagnostic_tests_efps, 
                                                          type1: type1, 
                                                          type1_type: type1_type
            end
          when "adverse"
            #efps.link_to_type1 = arms_efps
            #t1_efps << efps
            #efps.extraction_forms_projects_section_option = ExtractionFormsProjectsSectionOptionWrapper.create ef.adverse_event_display_arms, ef.adverse_event_display_total
            #adverse_events_efps = efps
            #t2_efps << ExtractionFormsProjectsSectionWrapper.new(s)
            #TODO
          when "quality", "arm_details","outcome_details", "quality_details", "diagnostic_test_details","design", "baselines"
            section = Section.find_or_create_by(name: ef_section["section_name"].titleize)
            t2_efps << combined_efp.extraction_forms_projects_sections.find_or_create_by(section: section, extraction_forms_projects_section_type: @efps_type_2)
          when "results"
            section = Section.find_or_create_by(name: ef_section["section_name"].titleize)
            combined_efp.extraction_forms_projects_sections.find_or_create_by(section: section, extraction_forms_projects_section_type: @efps_type_results)
          else
            Rails.logger.debug "Unknown section name:"
            Rails.logger.debug ef_section.to_yaml
          end
        end

        t2_efps.each do |efps|
          efps.extraction_forms_projects_section_option.update by_type1: false, include_total: false
          case efps.section.name
          when "Arm Details"
            efsos = db.query("SELECT * FROM ef_section_options where section='arm_detail' AND extraction_form_id=#{ef["id"]}")
            efsos.each do |efso|
              if efso["by_arm"] == 1
                efps.update link_to_type1: arms_efps
              end
              efps.extraction_forms_projects_section_option.update \
                by_type1: (if efso["by_arm"] == 1 then true else false end), 
                include_total: (if efso["include_total"] == 1 then true else false end)
            end

            migrate_questions efps, ef["id"], 'arm_detail', ef_key_questions
          when "Outcome Details"
            efsos = db.query("SELECT * FROM ef_section_options where section='outcome_detail' AND extraction_form_id=#{ef["id"]}")
            efsos.each do |efso|
              if efso["by_outcome"] == 1
                efps.update link_to_type1: outcomes_efps
              end
              efps.extraction_forms_projects_section_option.update \
                by_type1: (if efso["by_outcome"] == 1 then true else false end),
                include_total: (if efso["include_total"] == 1 then true else false end)
            end
            migrate_questions efps, ef["id"], 'outcome_detail', ef_key_questions
          when "Diagnostic Test Details"
            efsos = db.query("SELECT * FROM ef_section_options where section='diagnostic_test' AND extraction_form_id=#{ef["id"]}")
            efsos.each do |efso|
              if efso["by_diagnostic_test"]
                efps.update link_to_type1: diagnostic_tests_efps
              end
              efps.extraction_forms_projects_section_option.update \
                by_type1: (if efso["by_diagnostic_test"] == 1 then true else false end), 
                include_total: (if efso["include_total"] == 1 then true else false end)
            end
            migrate_questions efps, ef["id"], 'diagnostic_test_detail', ef_key_questions
          when "Adverse"
            #efps.link_to_type1 = adverse_events_efps
            #efps.extraction_forms_projects_section_option = ExtractionFormsProjectsSectionOptionWrapper.new true, false
          when "Design"
            migrate_questions efps, ef["id"], 'design_detail', ef_key_questions
          when "Quality"
            qdf_arr = db.query("SELECT * FROM quality_dimension_fields where extraction_form_id=#{ef["id"]}")
            qrf_arr = db.query("SELECT * FROM quality_rating_fields where extraction_form_id=#{ef["id"]}")

            migrate_quality_questions efps, ef["id"], qdf_arr, qrf_arr, ef_key_questions
          when "Baselines"
            migrate_questions efps, ef["id"], 'baseline_characteristic', ef_key_questions
          else
            Rails.logger.debug "Unknown section name:"
            Rails.logger.debug efps.section.to_yaml
          end
        end
      end
    end

    def get_questions table_root, ef_id
      db.query "SELECT * FROM #{table_root}s where extraction_form_id=#{ef_id} ORDER BY question_number ASC"
    end

    def get_question_fields table_root, ef_id
      qs = db.query "SELECT * FROM #{table_root}s where extraction_form_id=#{ef_id} ORDER BY question_number ASC"
      q_ids_string = qs.map{|q| q["id"]}.join ","

      if q_ids_string.present?
        return db.query "SELECT * FROM #{table_root}_fields where #{table_root}_id IN (#{q_ids_string}) ORDER BY row_number ASC"
      else
        return []
      end
    end

    def get_data_points table_root, ef_id
      db.query "SELECT * FROM #{table_root}_data_points where extraction_form_id=#{ef_id}"
    end

    def get_qdf_dropdown_options(quality_dimension)
      qd_text = quality_dimension["title"]
      
      output_array = []	
      fn = File.dirname(File.expand_path(__FILE__)) + '/legacy_quality_dimensions.yml'
      dimensions_file = YAML::load(File.open(fn))
      output_array << ["", ""]
      
      finished = false
      if (defined?(dimensions_file) && !dimensions_file.nil?)
        # go through quality_dimensions.yml
        dimensions_file.each do |section|
          if defined?(section['dimensions']) && !section['dimensions'].nil?
            section['dimensions'].each do |dimension|
              if !finished			
                # test if dimension['question'] equals first part of @qd_text
                if defined?(dimension['question']) && !dimension['question'].nil? && (qd_text.starts_with?(dimension['question']))
                  if !dimension['options'].nil?
                    dimension['options'].each do |option|
                      output_array << [option['option'], option['option']]
                    end
                    output_array << ["Other...","other"]
                  end
                  finished = true
                end # end compare question and yml question	
              end # end finished
            end #end section.each
          end #end 
        end
      end
      # if not finished (no match found), create a default array
      if (!finished)
        output_array << ["Yes", "Yes"]								
        output_array << ["No", "No"]								
        output_array << ["Unsure", "Unsure"]								
        output_array << ["No Data", "No Data"]								
        output_array << ["Not Applicable", "Not Applicable"]
        output_array << ["Other...","other"]
      end
      return output_array
    end

    def migrate_quality_questions efps, ef_id, qdf_arr, qrf_arr, ef_key_questions
      qdf_data_points = get_data_points 'quality_dimension', ef_id
      qrf_data_points = get_data_points 'quality_rating', ef_id
      qdf_arr.each do |qdf|
        options_arr = get_qdf_dropdown_options qdf

        qdf_title = qdf["title"]
        qdf_title =~ /(.*) \[(.*)\]$/

        name = $1 || qdf_title
        description = qdf["field_notes"]

        question = Question.create! name: name,
                                   description: description,
                                   extraction_forms_projects_section: efps
        ef_key_questions.each do |kq|
          kqp = get_srdrplus_key_question(kq["key_question_id"])
          if kqp.present?
            KeyQuestionsProjectsQuestion.create! key_questions_project: kqp,
                                                 question: question
          else
            Rails.logger.debug "Missing extraction form key question:"
            Rails.logger.debug kq.to_yaml
          end
        end

        question.question_rows.first.update! name: "Value:"
        question.question_rows.create! name: "Notes:"

        values_qrc = question.question_rows.first.question_row_columns.first
        question.question_rows.second.question_row_columns.first
        values_qrc.update! question_row_column_type: @qrc_type_radio
        values_qrc.question_row_columns_question_row_column_options.where(question_row_column_option: @qrco_answer_choice).destroy_all

        options_arr.each do |o|
          if not o[0].present? then next end
          if o[0] == "Other..."
            qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_or_create_by! question_row_column: values_qrc,
                                                                         question_row_column_option: @qrco_answer_choice,
                                                                         name: @other_please_specify

            set_qrcqrco values_qrc.id, qrcqrco.name, qrcqrco

            ff = FollowupField.create! question_row_columns_question_row_column_option: qrcqrco
            set_followup_field qrcqrco
          else
            qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_or_create_by! question_row_column: values_qrc,
                                                                         question_row_column_option: @qrco_answer_choice,
                                                                         name: o[0]

            set_qrcqrco values_qrc.id, o[0], qrcqrco
          end
        end

        qdf_data_points.select{|dp| dp["quality_dimension_field_id"]==qdf["id"]}.each do |dp|
          queue_data_point dp, values_qrc.question_row_column_fields.first, "quality_dimension"
        end
      end

      qrf_name = "Adjust Quality Rating (for Key Questions: #{(ef_key_questions.map{|ef_kq| get_srdrplus_key_question(ef_kq["key_question_id"]).try(:ordering).try(:position).to_s}-[""]).join(", ")})"
      qrf_question = Question.create name: qrf_name,
                                 description: "",
                                 extraction_forms_projects_section: efps

      qrf_question.question_rows.first.update! name: "Quality Guideline Used:"
      qrf_question.question_rows.create! name: "Select Current Overall Rating:"
      qrf_question.question_rows.create! name: "Notes on this Rating:"
      rating_qrc = qrf_question.question_rows.second.question_row_columns.first
      rating_qrc.update! question_row_column_type: @qrc_type_dropdown
      rating_qrc.question_row_columns_question_row_column_options.where(question_row_column_option: @qrco_answer_choice).destroy_all

      ef_key_questions.each do |kq|
        KeyQuestionsProjectsQuestion.create key_questions_project: get_srdrplus_key_question(kq["key_question_id"]),
                                            question: qrf_question
      end
      
      qrf_arr.each do |qrf|
        qrcqrco = QuestionRowColumnsQuestionRowColumnOption.find_or_create_by! question_row_column: rating_qrc,
                                                                     question_row_column_option: @qrco_answer_choice,
                                                                     name: qrf["rating_item"]

        set_qrcqrco rating_qrc.id, qrf["rating_item"], qrcqrco
      end

      qrf_data_points.each do |dp|
        queue_data_point dp, rating_qrc.question_row_column_fields.first, "quality_rating"
      end
    end

    def migrate_questions efps, ef_id, table_root, ef_key_questions
      legacy_questions = get_questions table_root, ef_id
      legacy_question_fields = get_question_fields table_root, ef_id
      legacy_data_points = get_data_points table_root, ef_id

      legacy_questions.each do |q|
        legacy_question_id = q["id"]
        name = q["question"]
        description = q["instruction"]
        question_type = q["field_type"]
        include_other = q["include_other_as_option"]
        is_matrix = q["is_matrix"]
        question = Question.create name: name,
                                   description: description,
                                   extraction_forms_projects_section: efps

        ef_key_questions.each do |kq|
          KeyQuestionsProjectsQuestion.create key_questions_project: get_srdrplus_key_question(kq["key_question_id"]),
                                              question: question
        end

        q_fields = legacy_question_fields.select{|qf| qf["#{table_root}_id"] == legacy_question_id}
        q_fields = (q_fields.select{|qf| qf["row_number"] != -1} + q_fields.select{|qf| qf["row_number"] == -1})
        q_data_points = legacy_data_points

        case question_type
        when "text"
          qrcf = question.question_rows.first.question_row_columns.first.question_row_column_fields.first 

          q_data_points.select{|dp| dp["#{table_root}_field_id"] == q["id"]}.each do |dp|
            queue_data_point dp, qrcf
          end
        when "checkbox"
          migrate_multiple_choice_question question, @qrc_type_checkbox, q, q_fields, q_data_points, table_root
        when "radio"
          migrate_multiple_choice_question question, @qrc_type_radio, q, q_fields, q_data_points, table_root
        when "select"
          migrate_multiple_choice_question question, @qrc_type_dropdown, q, q_fields, q_data_points, table_root
        when "matrix_select"
          migrate_matrix_dropdown_question question, q, q_data_points, table_root
        when "matrix_radio"
          migrate_multi_row_question question, @qrc_type_radio, q, q_fields, q_data_points, table_root
        when "matrix_checkbox"
          migrate_multi_row_question question, @qrc_type_checkbox, q, q_fields, q_data_points, table_root
        else
        end
      end
    end

    def migrate_multiple_choice_question question, question_type, legacy_question, fields_of_legacy_question, data_points_of_legacy_question, table_root
      question_row_column = question.question_rows.first.question_row_columns.first
      question_row_column.update question_row_column_type: question_type
      
      question_row_column.question_row_columns_question_row_column_options.where(question_row_column_option: @qrco_answer_choice).destroy_all
      fields_of_legacy_question.each do |qf|
        qrcqrco = nil
        if qf["row_number"] == -1
          qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create name: @other_please_specify,
                                                                     question_row_column_option: @qrco_answer_choice,
                                                                     question_row_column: question_row_column
          ff = FollowupField.create question_row_columns_question_row_column_option: qrcqrco
          set_followup_field qrcqrco
          set_qrcqrco question_row_column.id, @other_please_specify, qrcqrco
        else
          if qf["has_subquestion"] == 1
            qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create name: qf["option_text"]+"..."+qf["subquestion"],
                                                                       question_row_column_option: @qrco_answer_choice,
                                                                       question_row_column: question_row_column
            FollowupField.create question_row_columns_question_row_column_option: qrcqrco
            set_followup_field qrcqrco
            set_qrcqrco question_row_column.id, qf["option_text"], qrcqrco
          else
            qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create name: qf["option_text"],
                                                                       question_row_column_option: @qrco_answer_choice,
                                                                       question_row_column: question_row_column
            set_qrcqrco question_row_column.id, qrcqrco.name, qrcqrco
          end
        end

        dps = data_points_of_legacy_question.select{|dp| dp["#{table_root}_field_id"]==legacy_question["id"]}
        dps.each do |dp|
          queue_data_point dp, question_row_column.question_row_column_fields.first
        end
      end
    end

    def migrate_multi_row_question question, question_type, legacy_question, fields_of_legacy_question, data_points_of_legacy_question, table_root
      r_farr = db.query "SELECT * FROM #{table_root}_fields WHERE #{table_root}_id=#{legacy_question["id"]} and column_number=0 ORDER BY row_number ASC"
      c_farr = db.query "SELECT * FROM #{table_root}_fields WHERE #{table_root}_id=#{legacy_question["id"]} and row_number=0 ORDER BY column_number ASC"

      qr = question.question_rows.first
      qrc = qr.question_row_columns.first
      _is_first = true

      (r_farr.select{|rf| rf["row_number"] != -1} + r_farr.select{|rf| rf["row_number"] == -1}).each do |rf|
        if _is_first
          _is_first = false
        else
          qr = QuestionRow.create question: question
          qrc = qr.question_row_columns.first
        end

        if rf["row_number"] == -1
          qr.update name: @other_please_specify
        else
          qrc.update question_row_column_type: question_type
          qr.update name: rf["option_text"]
        end

        qrc.question_row_columns_question_row_column_options.where(question_row_column_option: @qrco_answer_choice).destroy_all
        c_farr.each do |cf|
          qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create name: cf["option_text"],
                                                                     question_row_column_option: @qrco_answer_choice,
                                                                     question_row_column: qrc
          set_qrcqrco qrc.id, qrcqrco.name, qrcqrco
        end

        data_points_of_legacy_question.select{|dp| dp["row_field_id"] == rf["id"]}.each do |dp|
          queue_data_point dp, qrc.question_row_column_fields.first
        end
      end
    end
    
    def migrate_matrix_dropdown_question question, legacy_question, data_points_of_legacy_question, table_root
      r_farr = db.query "SELECT * FROM #{table_root}_fields WHERE #{table_root}_id=#{legacy_question["id"]} and column_number=0 ORDER BY row_number ASC"
      c_farr = db.query "SELECT * FROM #{table_root}_fields WHERE #{table_root}_id=#{legacy_question["id"]} and row_number=0 ORDER BY column_number ASC"

      _is_first = true

      (r_farr.select{|rf| rf["row_number"] != -1} + r_farr.select{|rf| rf["row_number"] == -1}).each do |rf|
        if _is_first
          _is_first = false
          qr = question.question_rows.first
          qr.question_row_columns.destroy_all
        else
          qr = QuestionRow.create question: question
          qr.question_row_columns.destroy_all
        end

        if rf["row_number"] == -1
          qr.update name: @other_please_specify
        else
          qr.update name: rf["option_text"]
        end

        c_farr.each do |cf|
          qrc = QuestionRowColumn.create question_row: qr,
                                         name: cf["option_text"],
                                         question_row_column_type: @qrc_type_dropdown

          matrix_dropdown_options = db.query "SELECT * FROM matrix_dropdown_options WHERE row_id=#{rf["id"]} and column_id=#{cf["id"]} ORDER BY option_number"

          dropdown_options = []
          other_name = ""

          matrix_dropdown_options.each do |op|
            dropdown_options << op["option_text"]
          end

          if not dropdown_options.empty?
            qrc.update question_row_column_type: @qrc_type_dropdown
            qrc.question_row_columns_question_row_column_options.where(question_row_column_option: @qrco_answer_choice).destroy_all
            dropdown_options.each do |op|
              qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create name: op,
                                                                         question_row_column_option: @qrco_answer_choice,
                                                                         question_row_column: qrc
              set_qrcqrco qrc.id, qrcqrco.name, qrcqrco
            end
          else
            qrc.update question_row_column_type: @qrc_type_text
          end

          if legacy_question["include_other_as_option"] == 1
            qrcqrco = QuestionRowColumnsQuestionRowColumnOption.create name: @other_please_specify,
                                                                       question_row_column_option: @qrco_answer_choice,
                                                                       question_row_column: qrc
            set_qrcqrco qrc.id, qrcqrco.name, qrcqrco
            FollowupField.create question_row_columns_question_row_column_option: qrcqrco
            set_followup_field qrcqrco
          end

          data_points_of_legacy_question.select{|dp| dp["column_field_id"] == cf["id"] && dp["row_field_id"] == rf["id"]}.each do |dp|
            queue_data_point dp, qrc.question_row_column_fields.first
          end
        end
      end
    end

    def migrate_key_questions
      kqs = db.query "SELECT * FROM key_questions where project_id=#{@legacy_project_id}"
      srdrplus_project = get_srdrplus_project @legacy_project_id
      kqs.each_with_index do |kq,ix|
        srdrplus_kq = KeyQuestion.find_or_create_by name: kq["question"]
        srdrplus_kqp = KeyQuestionsProject.create key_question: srdrplus_kq, project: srdrplus_project
        srdrplus_kqp.ordering.update! position: ix+1

        set_srdrplus_key_question kq["id"], srdrplus_kqp
      end
    end

    def migrate_study_as_extraction study_hash, citations_project_id
      extraction = Extraction.create(projects_users_role: @default_projects_users_role,
                                     citations_project_id: citations_project_id,
                                     consolidated: false,
                                     project: get_srdrplus_project(@legacy_project_id))

      #set_srdrplus_extraction study_hash["id"], extraction
      migrate_type1_data study_hash["id"], extraction
      migrate_study_data study_hash["id"], extraction
    end

    def migrate_type1_data study_id, extraction
      arms = db.query "SELECT * FROM arms where study_id=#{study_id}"
      outcomes = db.query "SELECT * FROM outcomes where study_id=#{study_id}"
      diagnostic_tests = db.query "SELECT * FROM diagnostic_tests where study_id=#{study_id}"
      adverse_events = db.query "SELECT * FROM adverse_events where study_id=#{study_id}"
      
      arms.each_with_index do |arm, ix|
        t1 = Type1.find_or_create_by name: arm["title"], 
                                     description: arm["description"]
        Suggestion.find_or_create_by suggestable: t1, user: migration_user

        eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
          extraction: extraction,
          extraction_forms_projects_section: get_efps("arms")
        eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by \
          extractions_extraction_forms_projects_section: eefps, 
          type1: t1
        if eefps_t1.ordering.nil? then Ordering.find_or_create_by(orderable: eefps_t1, position: ix+1) else eefps_t1.ordering.update(position: ix+1) end
        set_eefpst1 "arm", arm["id"], eefps_t1
      end

      results_data_queue = []
      outcomes.each_with_index do |outcome, ix|
        t1 = Type1.find_or_create_by name: outcome["title"], 
                                     description: outcome["description"]
        Suggestion.find_or_create_by suggestable: t1, user: migration_user

        eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
          extraction: extraction,
          extraction_forms_projects_section: get_efps("outcomes")
        eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by \
          extractions_extraction_forms_projects_section: eefps, 
          type1: t1, 
          type1_type: @type1_types[outcome["outcome_type"]]
        set_eefpst1 "outcome", outcome["id"], eefps_t1
        if eefps_t1.ordering.nil? then Ordering.find_or_create_by(orderable: eefps_t1, position: ix+1) else eefps_t1.ordering.update(position: ix+1) end

        eefps_t1.extractions_extraction_forms_projects_sections_type1_rows.destroy_all

        eefpst1r = nil
        subgroups = db.query "SELECT * FROM outcome_subgroups where outcome_id=#{outcome["id"]}"
        subgroups.each do |subgroup|
          population_name = PopulationName.find_or_create_by \
            name: subgroup["title"], 
            description: subgroup["description"] || ""
          eefpst1r = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by \
            extractions_extraction_forms_projects_sections_type1: eefps_t1, 
            population_name: population_name
          results_data_queue << [subgroup, outcome, eefpst1r]
        end

        if eefpst1r.present?
          eefpst1r.extractions_extraction_forms_projects_sections_type1_row_columns.destroy_all

          timepoints = db.query "SELECT * FROM outcome_timepoints where outcome_id=#{outcome["id"]}"
          timepoints.each do |timepoint|
            timepoint_name = TimepointName.find_or_create_by \
              name: timepoint["number"], 
              unit: timepoint["time_unit"]
            tp = ExtractionsExtractionFormsProjectsSectionsType1RowColumn.find_or_create_by \
              extractions_extraction_forms_projects_sections_type1_row: eefpst1r, 
              timepoint_name: timepoint_name
            set_tp timepoint["id"], tp
          end
        end
      end

      results_data_queue.each do |subgroup, outcome, eefpst1r|
        migrate_results_data subgroup, outcome, eefpst1r
      end

      diagnostic_results_data_queue = []
      diagnostic_tests.each_with_index do |diagnostic_test, ix|
        t1 = Type1.find_or_create_by name: diagnostic_test["title"], 
                                     description: diagnostic_test["description"]
        Suggestion.find_or_create_by suggestable: t1, user: migration_user

        eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
          extraction: extraction,
          extraction_forms_projects_section: get_efps("diagnostic_tests")
        eefps_t1 = ExtractionsExtractionFormsProjectsSectionsType1.find_or_create_by \
          extractions_extraction_forms_projects_section: eefps, \
          type1: t1, \
          type1_type: @type1_types[diagnostic_test["test_type"]]
        set_eefpst1 "diagnostic_test", diagnostic_test["id"], eefps_t1
        if eefps_t1.ordering.nil? then Ordering.find_or_create_by(orderable: eefps_t1, position: ix+1) else eefps_t1.ordering.update(position: ix+1) end

        eefps_t1.extractions_extraction_forms_projects_sections_type1_rows.destroy_all

        eefpst1r = nil
        thresholds = db.query "SELECT * FROM diagnostic_test_thresholds where diagnostic_test_id=#{diagnostic_test["id"]}"

        thresholds.each do |threshold|
          population_name = PopulationName.find_or_create_by! \
            name: threshold["threshold"],
            description: ""
          eefpst1r = ExtractionsExtractionFormsProjectsSectionsType1Row.find_or_create_by! \
            extractions_extraction_forms_projects_sections_type1: eefps_t1, 
            population_name: population_name
          diagnostic_results_data_queue << [threshold, diagnostic_test, eefpst1r]
        end
      end

      diagnostic_results_data_queue.each do |diagnostic_results_data_queue|
      end

      adverse_events.each do |adverse_event|
        t1 = Type1.find_or_create_by name: adverse_event["title"], 
                                     description: adverse_event["description"]
        Suggestion.find_or_create_by suggestable: t1, user: migration_user
        ## TODO: Adverse Event stuff
      end
    end

    def migrate_results_data legacy_subgroup, legacy_outcome, eefpst1r
      outcome_data_entries = db.query "SELECT * FROM outcome_data_entries where outcome_id=#{legacy_outcome["id"]} and subgroup_id=#{legacy_subgroup["id"]}"
      bac_arr = db.query "SELECT * FROM comparisons where outcome_id=#{legacy_outcome["id"]} and subgroup_id=#{legacy_subgroup["id"]} and within_or_between='between'"
      wac_arr = db.query "SELECT * FROM comparisons where outcome_id=#{legacy_outcome["id"]} and subgroup_id=#{legacy_subgroup["id"]} and within_or_between='within'"

      rss_d = eefpst1r.result_statistic_sections.find_or_create_by(result_statistic_section_type: @rss_type_descriptive)
      rss_b = eefpst1r.result_statistic_sections.find_or_create_by(result_statistic_section_type: @rss_type_between)
      rss_w = eefpst1r.result_statistic_sections.find_or_create_by(result_statistic_section_type: @rss_type_within)
      eefpst1r.result_statistic_sections.find_or_create_by(result_statistic_section_type: @rss_type_net).result_statistic_sections_measures.destroy_all
      rss_d.result_statistic_sections_measures.destroy_all
      rss_b.result_statistic_sections_measures.destroy_all
      rss_w.result_statistic_sections_measures.destroy_all

      outcome_data_entries.each do |ode|
        outcome_measures = db.query "SELECT * FROM outcome_measures where outcome_data_entry_id=#{ode["id"]}"
        outcome_measures.each do |om|
          rssm = ResultStatisticSectionsMeasure.find_or_create_by measure: Measure.find_or_create_by(name: om["title"]),
                                                                  result_statistic_section: rss_d
          tp = get_tp ode["timepoint_id"]

          outcome_data_points = db.query "SELECT * FROM outcome_data_points where outcome_measure_id=#{om["id"]}"
          outcome_data_points.each do |odp|
            record_name = odp["value"]
            arm_eefpst1 = get_eefpst1 'arm', odp["arm_id"]

            if arm_eefpst1.present? and tp.present?
              tar = TpsArmsRssm.find_or_create_by extractions_extraction_forms_projects_sections_type1: arm_eefpst1,
                                                  result_statistic_sections_measure: rssm,
                                                  timepoint: tp
              Record.find_or_create_by recordable: tar, name: odp["value"] || ""
            else
              Rails.logger.debug "Cannot find necessary references to create data record:"
              Rails.logger.debug odp.to_yaml
            end
          end
        end
      end

      comp_dedup_dict = {}
      comp_dict = {}
      wac_arr.each do |wac|
        comp_arr = db.query "SELECT * FROM comparators where comparison_id=#{wac["id"]}"
        comp_arr.each do |comp|
          if comp_dedup_dict.key? comp["comparator"]
            new_comparison = comp_dedup_dict[comp["comparator"]]
          elsif comp["comparator"] == ""
            new_comparison = Comparison.create is_anova: false
          elsif comp["comparator"] == "000" 
            #TODO can this actually happen?
            new_comparison = Comparison.create is_anova: true
          else
            new_comparison = Comparison.create is_anova: false
            tparr = comp["comparator"].split("_").map{|tp_id| get_tp(tp_id) }.uniq - [nil]
            tparr.each do |tp|
              cg = ComparateGroup.create comparison: new_comparison
              ce = ComparableElement.create comparable: tp
              comparate = Comparate.create comparate_group: cg, comparable_element: ce
            end
          end
          ComparisonsResultStatisticSection.find_or_create_by comparison: new_comparison, result_statistic_section: rss_w
          comp_dedup_dict[comp["comparator"]] = new_comparison
          comp_dict[comp["id"]] = new_comparison
        end

        comp_measures = db.query "SELECT * FROM comparison_measures where comparison_id=#{wac["id"]}"
        comp_measures.each do |cm| 
          rssm = ResultStatisticSectionsMeasure.find_or_create_by measure: Measure.find_or_create_by(name: cm["title"]),
                                                                  result_statistic_section: rss_w

          comp_dps = db.query "SELECT * FROM comparison_data_points where comparison_measure_id=#{cm["id"]}"
          comp_dps.each do |comp_dp|
            eefpst1 = get_eefpst1("arm", comp_dp["arm_id"])
            if eefpst1.present? and comp_dict[comp_dp["comparator_id"]].present?
              car = ComparisonsArmsRssm.find_or_create_by comparison: comp_dict[comp_dp["comparator_id"]], 
                                                          extractions_extraction_forms_projects_sections_type1: eefpst1,
                                                          result_statistic_sections_measure: rssm
              Record.find_or_create_by recordable: car, name: comp_dp["value"] || ""
            else
              Rails.logger.debug "Cannot find necessary references to create data record:"
              Rails.logger.debug comp_dp.to_yaml
            end
          end
        end
      end

      comp_dedup_dict = {}
      comp_dict = {}
      bac_arr.each do |bac|
        comp_arr = db.query "SELECT * FROM comparators where comparison_id=#{bac["id"]}"
        comp_arr.each do |comp|
          if comp_dedup_dict.key? comp["comparator"]
            new_comparison = comp_dedup_dict[comp["comparator"]]
          elsif comp["comparator"] == ""
            new_comparison = Comparison.create is_anova: false
          elsif comp["comparator"] == "000" 
            new_comparison = Comparison.create is_anova: true
          else
            new_comparison = Comparison.create is_anova: false
            armarr = comp["comparator"].split("_").map{|arm_id| get_eefpst1("arm", arm_id)}.uniq - [nil]

            armarr.each do |eefpst1|
              cg = ComparateGroup.create comparison: new_comparison
              ce = ComparableElement.create comparable: eefpst1
              comparate = Comparate.create comparate_group: cg, comparable_element: ce
            end
          end
          ComparisonsResultStatisticSection.find_or_create_by comparison: new_comparison, result_statistic_section: rss_b
          comp_dedup_dict[comp["comparator"]] = new_comparison
          comp_dict[comp["id"]] = new_comparison
        end

        comp_measures = db.query "SELECT * FROM comparison_measures where comparison_id=#{bac["id"]}"
        comp_measures.each do |cm| 
          rssm = ResultStatisticSectionsMeasure.find_or_create_by measure: Measure.find_or_create_by(name: cm["title"]),
                                                                  result_statistic_section: rss_b

          comp_dps = db.query "SELECT * FROM comparison_data_points where comparison_measure_id=#{cm["id"]}"
          comp_dps.each do |comp_dp|
            tp = get_tp(bac["group_id"])
            if tp.present? and comp_dict[comp_dp["comparator_id"]].present?
              tcr = TpsComparisonsRssm.find_or_create_by comparison: comp_dict[comp_dp["comparator_id"]], 
                                                          timepoint: tp,
                                                          result_statistic_sections_measure: rssm
              Record.find_or_create_by recordable: tcr, name: comp_dp["value"] || ""
            else
              Rails.logger.debug "Cannot find necessary references to create data record:"
              Rails.logger.debug comp_dp.to_yaml
            end
          end
        end
      end
    end

    def migrate_study_data study_id, extraction
      get_data_point_queue_for_study(study_id).each do |q_id, q_item|
        case q_item[:dp_type]
        when 'quality_rating'
          migrate_quality_rating_data study_id, extraction, q_item
        when 'quality_dimension'
          migrate_quality_dimension_data study_id, extraction, q_item
        else
          migrate_question_data study_id, extraction, q_item
        end
      end
    end

    def migrate_quality_dimension_data study_id, extraction, q_item
      values_qrcf = q_item[:qrcf]
      question = values_qrcf.question
      notes_qrcf = question.question_rows.second.question_row_columns.first.question_row_column_fields.first
      efps = question.extraction_forms_projects_section
      data_points = q_item[:data_points]

      eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
        extraction: extraction,
        extraction_forms_projects_section: efps,
        link_to_type1: nil

      values_eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: values_qrcf,
        extractions_extraction_forms_projects_sections_type1: nil

      notes_eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: notes_qrcf,
        extractions_extraction_forms_projects_sections_type1: nil

      data_points.each do |dp|
        qrcqrco_id = get_qrcqrco(values_qrcf.question_row_column.id, dp["value"])
        Record.find_or_create_by recordable: notes_eefps_qrcf, name: dp["notes"] || ""
        if qrcqrco_id.present?
          Record.find_or_create_by recordable: values_eefps_qrcf, name: qrcqrco_id.to_s
        else
          ff = get_ff_by_qrc values_qrcf.question_row_column.id
          other_qrcqrco_id = get_qrcqrco(values_qrcf.question_row_column.id, @other_please_specify).to_s
          if ff.present? and other_qrcqrco_id.present? and dp["value"].present?
            eefps_ff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by \
              extractions_extraction_forms_projects_section: eefps,
              followup_field: ff,
              extractions_extraction_forms_projects_sections_type1_id: nil
            Record.find_or_create_by recordable: values_eefps_qrcf, name: other_qrcqrco_id
            Record.find_or_create_by recordable: eefps_ff, name: dp["value"] || ""
          end
        end
      end
    end

    def migrate_quality_rating_data study_id, extraction, q_item
      question = q_item[:qrcf].question
      guideline_qrcf = question.question_rows.first.question_row_columns.first.question_row_column_fields.first
      rating_qrcf = question.question_rows.second.question_row_columns.first.question_row_column_fields.first
      notes_qrcf = question.question_rows.third.question_row_columns.first.question_row_column_fields.first

      efps = question.extraction_forms_projects_section
      data_points = q_item[:data_points]

      eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
        extraction: extraction,
        extraction_forms_projects_section: efps,
        link_to_type1: nil

      rating_eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: rating_qrcf,
        extractions_extraction_forms_projects_sections_type1: nil

      guideline_eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: guideline_qrcf,
        extractions_extraction_forms_projects_sections_type1: nil

      notes_eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
        extractions_extraction_forms_projects_section: eefps,
        question_row_column_field: notes_qrcf,
        extractions_extraction_forms_projects_sections_type1: nil

      data_points.each do |dp|
        qrcqrco_id = get_qrcqrco(rating_qrcf.question_row_column.id, dp["current_overall_rating"])
        Record.find_or_create_by! recordable: notes_eefps_qrcf, name: dp["notes"] || ""
        Record.find_or_create_by! recordable: guideline_eefps_qrcf, name: dp["guideline_used"] || ""
        if qrcqrco_id.present?
          Record.find_or_create_by! recordable: rating_eefps_qrcf, name: qrcqrco_id.to_s
        end
      end
    end

    def migrate_question_data study_id, extraction, q_item
      qrcf = q_item[:qrcf]
      qrc_id = qrcf.question_row_column.id
      question = qrcf.question
      question_type = q_item[:question_type]
      data_points = q_item[:data_points]
      if qrcf.question.extraction_forms_projects_section.extraction_forms_projects_section_option.by_type1
        eefpst1 = nil
        linked_eefps = nil
        table_root = nil
        data_points[0..0].each do |dp|
          linked_type1_efps = nil
          if dp.key? "arm_detail_field_id"
            table_root = "arm"
            linked_type1_efps = get_efps "arms"
          elsif dp.key? "design_detail_field_id"
            table_root = "design"
          elsif dp.key? "outcome_detail_field_id"
            table_root = "outcome"
            linked_type1_efps = get_efps "outcomes"
          elsif dp.key? "diagnostic_test_detail_field_id"
            table_root = "diagnostic_test"
            linked_type1_efps = get_efps "diagnostic_tests"
          elsif dp.key? "baseline_characteristic_field_id"
            table_root = "baseline_characteristic"
          elsif dp.key? "adverse_event_field_id"
            table_root = "adverse_event"
            linked_type1_efps = get_efps "adverse_events"
          else
            Rails.logger.debug "Unsupported data point:"
            Rails.logger.debug dp.to_yaml
          end
          linked_eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
            extraction: extraction,
            extraction_forms_projects_section: linked_type1_efps
        end

        eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
          extraction: extraction,
          extraction_forms_projects_section: qrcf.question.extraction_forms_projects_section,
          link_to_type1: linked_eefps

        adict = {}
        data_points.each do |dp|
          eefpst1 = get_eefpst1 table_root, dp[table_root + "_id"] 
          adict[eefpst1&.id] ||= []
          adict[eefpst1&.id] << dp
        end

        adict.each do |eefpst1_id, dps|
          eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
            extractions_extraction_forms_projects_section: eefps,
            question_row_column_field: qrcf,
            extractions_extraction_forms_projects_sections_type1_id: eefpst1_id

          case question_type
          when @qrc_type_text
            Record.find_or_create_by recordable: eefps_qrcf, name: dps.first["value"] || ""
          when @qrc_type_checkbox
            record_name = "[" + (dps.map{|dp| get_qrcqrco(qrc_id, dp["value"]).to_s} - [nil, "", " "]).join(", ") + "]"
            Record.find_or_create_by recordable: eefps_qrcf, name: record_name
            dps.each do |dp|
              ff = get_ff_by_qrcqrco get_qrcqrco(qrc_id, dp["value"])
              if ff.present? and dp["subquestion_value"]
                eefps_ff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by \
                  extractions_extraction_forms_projects_section: eefps,
                  followup_field: ff,
                  extractions_extraction_forms_projects_sections_type1_id: eefpst1_id
                Record.find_or_create_by recordable: eefps_ff, name: dps.first["subquestion_value"] || ""
              end
            end
          when @qrc_type_radio, @qrc_type_dropdown
            qrcqrco_id = get_qrcqrco(qrc_id, dps.first["value"])
            if qrcqrco_id.present?
              Record.find_or_create_by recordable: eefps_qrcf, name: qrcqrco_id.to_s
              ff = get_ff_by_qrcqrco qrcqrco_id
              if ff.present? and dps.first["subquestion_value"].present?
                eefps_ff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by \
                  extractions_extraction_forms_projects_section: eefps,
                  followup_field: ff,
                  extractions_extraction_forms_projects_sections_type1_id: eefpst1_id
                Record.find_or_create_by recordable: eefps_ff, name: dps.first["subquestion_value"] || ""
              end
            else
              ff = get_ff_by_qrc qrc_id
              other_qrcqrco_id = get_qrcqrco(qrc_id, @other_please_specify).to_s
              if ff.present? and other_qrcqrco_id.present? and dps.first["value"].present?
                eefps_ff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by \
                  extractions_extraction_forms_projects_section: eefps,
                  followup_field: ff,
                  extractions_extraction_forms_projects_sections_type1_id: eefpst1_id
                Record.find_or_create_by recordable: eefps_qrcf, name: other_qrcqrco_id
                Record.find_or_create_by recordable: eefps_ff, name: dps.first["value"] || ""
              end
            end
          else
            Rails.logger.debug "Unsupported question type: #{question_type.try :name}"
            Rails.logger.debug q_item.to_yaml
          end
        end
      else
        eefps = ExtractionsExtractionFormsProjectsSection.find_or_create_by \
          extraction: extraction,
          extraction_forms_projects_section: qrcf.question.extraction_forms_projects_section,
          link_to_type1: nil

        eefps_qrcf = ExtractionsExtractionFormsProjectsSectionsQuestionRowColumnField.find_or_create_by \
          extractions_extraction_forms_projects_section: eefps,
          question_row_column_field: qrcf,
          extractions_extraction_forms_projects_sections_type1: nil

        case question_type
        when @qrc_type_text
          Record.find_or_create_by recordable: eefps_qrcf, name: data_points.first["value"] || ""
        when @qrc_type_checkbox
          record_name = "[" + (data_points.map{|dp| get_qrcqrco(qrc_id, dp["value"]).to_s} - [nil, "", " "]).join(", ") + "]"
          data_points.each do |dp|
            ff = get_ff_by_qrcqrco get_qrcqrco(qrc_id, dp["value"])
            if ff.present? and dp["subquestion_value"]
              eefps_ff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by \
                extractions_extraction_forms_projects_section: eefps,
                followup_field: ff,
                extractions_extraction_forms_projects_sections_type1_id: nil
              Record.find_or_create_by recordable: eefps_ff, name: dp["subquestion_value"] || ""
            end
          end
          Record.find_or_create_by recordable: eefps_qrcf, name: record_name
        when @qrc_type_radio, @qrc_type_dropdown
          record_name = get_qrcqrco(qrc_id, data_points.first["value"]).to_s
          if record_name.present?
            Record.find_or_create_by recordable: eefps_qrcf, name: record_name
          else
            ff = get_ff_by_qrc qrc_id
            other_qrcqrco_id = get_qrcqrco(qrc_id, @other_please_specify).to_s
            if ff.present? and other_qrcqrco_id.present? and data_points.first["value"].present?
              eefps_ff = ExtractionsExtractionFormsProjectsSectionsFollowupField.find_or_create_by \
                extractions_extraction_forms_projects_section: eefps,
                followup_field: ff,
                extractions_extraction_forms_projects_sections_type1_id: nil
              Record.find_or_create_by recordable: eefps_qrcf, name: other_qrcqrco_id
              Record.find_or_create_by recordable: eefps_ff, name: data_points.first["value"] || ""
            end
          end
        else
          Rails.logger.debug "Unsupported question type: #{question_type.try :name}"
          Rails.logger.debug q_item.to_yaml
        end
      end
    end

    def migrate_primary_publication_as_citation primary_publication_hash
      if primary_publication_hash["journal"]
        journal = Journal.find_or_create_by name: primary_publication_hash["journal"],
                                            volume: primary_publication_hash["volume"],
                                            issue: primary_publication_hash["issue"],
                                            publication_date: primary_publication_hash["year"] || ""
      end
      new_citation = Citation.new name: primary_publication_hash["title"] || "", 
                                  abstract: primary_publication_hash["abstract"] || "",
                                  journal: journal

      #TODO import key_words (do they even exist in srdr)

      #TODO separate authors
      #Author.new name: primary_publication_hash["author"]

      #if new_citation.save then return new_citation end
      return new_citation
    end

    def migrate_secondary_publication_as_citation secondary_publication_hash
      #TODO 
    end

    def migrate_author_string_as_separate_authors authors_string
      authors = []
      author_names = split_authors_string authors_string
      author_names.each do |author_name|
        authors << Author.find_or_create_by(name: author_name)
      end
      authors
    end

    def split_authors_string authors_string
      #TODO 
      []
    end

    def get_efp_type efs
      has_diagnostic = false
      has_standard = false
      efs.each do |ef_hash|
        if ef_hash["is_diagnostic"] == 1
          has_diagnostic = true
        else
          has_standard = true
        end
      end
      if has_diagnostic and has_standard
        return false
      elsif has_diagnostic
        return @efp_type_diagnostic
      else
        return @efp_type_standard
      end
    end
  end
end
