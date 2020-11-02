require 'mysql2'

def legacy_database
  @client ||= Mysql2::Client.new(Rails.configuration.database_configuration['legacy_production'])
end

namespace(:db) do
  namespace(:import_legacy) do
    desc "import legacy projects"
    task :projects => :environment do 
      projects = legacy_database.query("SELECT * FROM projects")
      projects.each do |project|
        puts project.to_json
        break
      end
    end
  end
end
