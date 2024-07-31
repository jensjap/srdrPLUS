namespace :citations_project do
  desc "Populate temp table with creator_id for each CitationsProject"
  task populate_temp_table: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      INSERT INTO temp_citations_projects_creators (citations_project_id, creator_id)
      SELECT cp.id, subquery.user_id
      FROM citations_projects cp
      JOIN (
        SELECT project_id, user_id,
               ROW_NUMBER() OVER (PARTITION BY project_id ORDER BY created_at) as row_num
        FROM projects_users
        WHERE permissions % 2 = 1
      ) subquery ON cp.project_id = subquery.project_id
      WHERE subquery.row_num = 1
    SQL
  end

  desc "Update CitationsProject with creator_id from temp table"
  task update_creator_id: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      UPDATE citations_projects AS cp
      JOIN temp_citations_projects_creators AS tc
      ON cp.id = tc.citations_project_id
      SET cp.creator_id = tc.creator_id
    SQL
  end

  desc "Clear temp table"
  task clear_temp_table: :environment do
    ActiveRecord::Base.connection.execute <<-SQL
      TRUNCATE TABLE temp_citations_projects_creators
    SQL
  end
end
