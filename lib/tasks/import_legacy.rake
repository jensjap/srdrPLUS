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
  end


  def migrate_legacy_srdr_project project_hash
    # DO I WANT TO CREATE USERS? probably no
    #purs = db.query "SELECT * FROM user_project_roles where project_id=#{project_hash["id"]}"
    #purs.each do |pur|
    #  break#DELETE THIS 
    #end

    project_id = project_hash["id"]
    studies_hash = db.query "SELECT * FROM studies where project_id=#{project_id}"
    studies_hash.each do |study_hash|
      study_id = study_hash["id"]

      primary_publication_hash = db.query "SELECT * FROM primary_publications where study_id=#{study_id}"
      citation = migrate_primary_publication_as_citation primary_publication_hash 

      migrate_study_as_extraction study_hash, citation.id
      break#DELETE THIS 
    end

    efs_hash = db.query "SELECT * FROM extraction_forms where project_id=#{project_id}"
    migrate_extraction_forms_as_combined_ef efs_hash
  end

  def migrate_extraction_forms_as_combined_ef ef_hash
    # do stuff
  end

  def migrate_study_as_extraction study_hash, citation_id
    p study_hash
  end
end
