require 'mysql2'

def db
  @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['legacy_production'])
end

namespace(:db) do
  namespace(:import_legacy) do
    desc "import legacy projects"
    task :projects => :environment do 
      projects = db.query("SELECT * FROM projects")
      projects.each do |project_hash|
        migrate_legacy_srdr_project project_hash
        break#DELETE THIS 
      end
    end
    
    @efps_type_1 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 1')
    @efps_type_2 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 2')
    @efps_type_results = ExtractionFormsProjectsSectionType.find_by(name: 'Results')
    @efps_type_4 = ExtractionFormsProjectsSectionType.find_by(name: 'Type 4')
    @efp_type_1 = ExtractionFormsProjectType.find_by
    

    def migrate_legacy_srdr_project project_hash
      # DO I WANT TO CREATE USERS? probably no
      #purs = db.query "SELECT * FROM user_project_roles where project_id=#{project_hash["id"]}"
      #purs.each do |pur|
      #  break#DELETE THIS 
      #end

      project_id = project_hash["id"]
      project_name = project_hash["title"]
      project_description = project_hash["description"]
      is_project_diagnostic = if project_hash["is_diagnostic"] == 1 then true else false end

      #TODO What to do with publications ?, is_public means published in SRDR
      @srdrplus_project = Project.new name: project_name, description: project_description
      @srdrplus_project.save #need to save, because i want the default efp
      @srdrplus_project.extraction_forms_projects.first.extraction_forms_projects_sections.destroy_all #need to delete default sections

      # Extraction Forms Migration
      efs = db.query "SELECT * FROM extraction_forms where project_id=#{project_id}"
      if is_project_diagnostic
        @srdrplus_project.extraction_forms_projects.update name: "Diagnostic Test"
        migrate_extraction_forms_as_standard_efp efs
      else
        migrate_extraction_forms_as_diagnostic_efp efs
      end

      studies_hash = db.query "SELECT * FROM studies where project_id=#{project_id}"
      studies_hash.each do |study_hash|
        study_id = study_hash["id"]

        primary_publications = db.query "SELECT * FROM primary_publications where study_id=#{study_id}"
        primary_publications.each do |primary_publication_hash|
          citation = migrate_primary_publication_as_citation primary_publication_hash 
          migrate_study_as_extraction study_hash, citation.id
        end

        break#DELETE THIS 
      end
    end

    def migrate_extraction_forms_as_standard_efp efs
      combined_efp = @srdrplus_project.extraction_forms_projects.first

      efs.each do |ef|
        ef_sections = db.query "SELECT * FROM extraction_form_sections where extraction_form_id=#{ef["id"]}"
        ef_sections.each do |ef_section|
          case ef_section.section_name
          when "arms"
            
            @extraction_forms_projects_sections << efps
            if adverse_events_efps.present? then adverse_events_efps.link_to_type1 = efps end
          when "outcomes"
            t1_efps << efps
            outcomes_efps = efps
          when "diagnostic_tests"
            t1_efps << efps
            diagnostic_tests_efps = efps
          when "adverse"
            efps.link_to_type1 = arms_efps
            t1_efps << efps
            efps.extraction_forms_projects_section_option = ExtractionFormsProjectsSectionOptionWrapper.new ef.adverse_event_display_arms, ef.adverse_event_display_total
            adverse_events_efps = efps
            t2_efps << ExtractionFormsProjectsSectionWrapper.new(s)

          when "quality", "arm_details","outcome_details", "quality_details", "diagnostic_test_details","design"
            t2_efps << efps
          else
            other_efps << efps
          end
           
        end
        break
      end
    end

    def migrate_study_as_extraction study_hash, citation_id
      return
    end

    def migrate_primary_publication_as_citation primary_publication_hash
      new_citation = Citation.new name: primary_publication_hash["title"], 
                                  abstract: primary_publication_hash["abstract"]


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
  end
end
