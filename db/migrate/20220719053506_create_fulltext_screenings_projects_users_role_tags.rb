class CreateFulltextScreeningsProjectsUsersRoleTags < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_projects_users_role_tags do |t|
      t.references :fulltext_screenings_projects_users_role, index: { name: 'ftspurt_on_ftspur' }
      t.references :tag, index: { name: 'ftspurt_on_r' }
      t.timestamps
    end
  end
end
