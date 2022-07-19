class CreateFulltextScreeningsProjectsUsersRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_projects_users_roles do |t|
      t.references :fulltext_screening, null: false, type: :bigint, index: { name: 'ftspur_on_fts' }
      t.references :projects_users_role, null: false, type: :bigint, index: { name: 'ftspur_on_pur' }
      t.timestamps
    end
    add_index :fulltext_screenings_projects_users_roles, %i[fulltext_screening_id projects_users_role_id],
              unique: true, name: 'pur_id_on_fts_id'
  end
end
