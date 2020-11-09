require 'mysql2'

def db
  @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['legacy_production'])
end

namespace(:db) do
  namespace(:import_legacy) do
    desc "import legacy projects"
    task :projects => :environment do 
      initialize_variables

      #projects = db.query("SELECT * FROM projects")
      projects = db.query("SELECT * FROM projects LIMIT 5")
      projects.each do |project_hash|
        begin
          @legacy_project_id = project_hash["id"]
          reset_project_variables
          migrate_legacy_srdr_project project_hash
        rescue => error
          puts error
          puts error.backtrace
          @legacy_project_id = nil
          reset_project_variables
        end
      end
    end
    
    def initialize_variables
      @efps_type_1 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 1')
      @efps_type_2 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 2')
      @efps_type_results = ExtractionFormsProjectsSectionType.find_by(name: 'Results')
      @efps_type_4 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 4')
      @efp_type_standard = ExtractionFormsProjectType.find_by(name: 'Standard')
      @efp_type_diagnostic = ExtractionFormsProjectType.find_by(name: 'Diagnostic Test')
    end

    def reset_project_variables
      @srdr_to_srdrplus_project_dict = {}
      @srdr_to_srdrplus_key_questions_dict = {}
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
      srdrplus_project.users << User.first
      srdrplus_project.projects_users.first.roles << Role.first
      @default_projects_users_role
    end

    def create_srdrplus_project project_hash
      project_id = project_hash["id"]
      project_name = project_hash["title"]
      project_description = project_hash["description"]

      #TODO What to do with publications ?, is_public means published in SRDR
      srdrplus_project = Project.new name: project_name, description: project_description
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
      elsif efp_type == @efp_type_diagnostic
        get_srdrplus_project(@legacy_project_id).extraction_forms_projects.update(extraction_forms_project_type: efp_type)
        migrate_extraction_forms_as_diagnostic_efp efs
      else
        migrate_extraction_forms_as_standard_efp efs
      end

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

        t1_efps = []
        t2_efps = []
        other_efps = []

        arms_efps = nil
        outcomes_efps = nil
        adverse_events_efps = nil
        diagnostic_tests_efps = nil

        ef_sections.each do |ef_section|
          section = Section.find_or_create_by(name: ef_section["section_name"].titleize)
          case ef_section["section_name"]
          when "arms"
            arms_efps = combined_efp.extraction_forms_projects_sections.create(section: section, extraction_forms_projects_section_type: @efps_type_1)
            if adverse_events_efps.present? then adverse_events_efps.link_to_type1 = arms_efps end
          when "outcomes"
            outcomes_efps = combined_efp.extraction_forms_projects_sections.create(section: section, extraction_forms_projects_section_type: @efps_type_1)
          when "diagnostic_tests"
            diagnostic_tests_efps = combined_efp.extraction_forms_projects_sections.create(section: section, extraction_forms_projects_section_type: @efps_type_4)
          when "adverse"
            #efps.link_to_type1 = arms_efps
            #t1_efps << efps
            #efps.extraction_forms_projects_section_option = ExtractionFormsProjectsSectionOptionWrapper.create ef.adverse_event_display_arms, ef.adverse_event_display_total
            #adverse_events_efps = efps
            #t2_efps << ExtractionFormsProjectsSectionWrapper.new(s)

          when "quality", "arm_details","outcome_details", "quality_details", "diagnostic_test_details","design"
            section = Section.find_or_create_by(name: ef_section["section_name"].titleize)
            t2_efps << combined_efp.extraction_forms_projects_sections.create(section: section, extraction_forms_projects_section_type: @efps_type_2)
          when "results"
            section = Section.find_or_create_by(name: ef_section["section_name"].titleize)
            combined_efp.extraction_forms_projects_sections.create(section: section, extraction_forms_projects_section_type: @efps_type_results)

          else
            #Baseline Characteristics
          end
        end

        t2_efps.each do |efps|
          efps.extraction_forms_projects_section_option.by_type1 = false
          efps.extraction_forms_projects_section_option.include_total = false
          case efps.section.name
          when "Arm Details"
            efsos = db.query("SELECT * FROM ef_section_options where section='arm_detail' AND extraction_form_id=#{ef["id"]}")
            efsos.each do |efso|
              if efso["by_arm"]
                efps.link_to_type1 = arms_efps
              end
              efps.extraction_forms_projects_section_option.include_total = efso["by_arm"]
              efps.extraction_forms_projects_section_option.include_total = efso["include_total"]
            end
          when "Outcome Details"
            efsos = db.query("SELECT * FROM ef_section_options where section='outcome_detail' AND extraction_form_id=#{ef["id"]}")
            efsos.each do |efso|
              if efso["by_outcome"]
                efps.link_to_type1 = outcomes_efps
              end
              efps.extraction_forms_projects_section_option.include_total = efso["by_outcome"]
              efps.extraction_forms_projects_section_option.include_total = efso["include_total"]
            end
          when "Diagnostic Test Details"
            efsos = db.query("SELECT * FROM ef_section_options where section='diagnostic_test' AND extraction_form_id=#{ef["id"]}")
            efsos.each do |efso|
              if efso["by_diagnostic_test"]
                efps.link_to_type1 = diagnostic_tests_efps
              end
              efps.extraction_forms_projects_section_option.include_total = efso["by_diagnostic_test"]
              efps.extraction_forms_projects_section_option.include_total = efso["include_total"]
            end
          when "Adverse"
            #efps.link_to_type1 = adverse_events_efps
            #efps.extraction_forms_projects_section_option = ExtractionFormsProjectsSectionOptionWrapper.new true, false
          else
          end
        end
        break
      end
    end

    def migrate_key_questions
      kqs = db.query "SELECT * FROM key_questions where project_id=#{@legacy_project_id}"
      srdrplus_project = get_srdrplus_project @legacy_project_id
      kqs.each do |kq|
        srdrplus_kq = KeyQuestion.find_or_create_by name: kq["question"]
        srdrplus_kqp = KeyQuestionsProject.create key_question: srdrplus_kq, project: srdrplus_project
        set_srdrplus_key_question kq["id"], srdrplus_kqp
      end
    end

    def migrate_study_as_extraction study_hash, citations_project_id
      extraction = Extraction.create(projects_users_role: @default_projects_users_role,
                                     citations_project_id: citations_project_id,
                                     consolidated: false,
                                     project: get_srdrplus_project(@legacy_project_id))
      return
    end

    def migrate_primary_publication_as_citation primary_publication_hash
      if primary_publication_hash["journal"]
        journal = Journal.find_or_create_by name: primary_publication_hash["journal"],
                                            volume: primary_publication_hash["volume"],
                                            issue: primary_publication_hash["issue"],
                                            publication_date: primary_publication_hash["year"]
      end
      new_citation = Citation.new name: primary_publication_hash["title"], 
                                  abstract: primary_publication_hash["abstract"],
                                  journal: journal

      #TODO import key_words (do they even exist in srdr)

      #TODO separate authors
      #Author.new name: primary_publication_hash["author"]

      #if new_citation.save then return new_citation end
      return new_citation
    end

    def migrate_secondary_publication_as_citation secondary_publication_hash
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
