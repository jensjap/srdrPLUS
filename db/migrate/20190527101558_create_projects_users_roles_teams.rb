class CreateProjectsUsersRolesTeams < ActiveRecord::Migration[5.2]
  def change
    create_table :projects_users_roles_teams, id: :integer do |t|
      t.references :projects_users_role, foreign_key: true, type: :integer
      t.references :team, foreign_key: true, type: :integer
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end
    add_index :projects_users_roles_teams, :deleted_at
    add_index :projects_users_roles_teams, :active
  end
end
