class CreateFulltextScreeningsProjectsUsersRoleReasons < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_projects_users_role_reasons do |t|
      t.references :fulltext_screenings_projects_users_role, index: { name: 'ftspurr_on_ftspur' }
      t.references :reason, index: { name: 'ftspurr_on_r' }
      t.timestamps
    end
  end
end
