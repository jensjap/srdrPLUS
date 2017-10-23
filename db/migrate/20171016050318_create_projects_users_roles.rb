class CreateProjectsUsersRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :projects_users_roles do |t|
      t.references :projects_user, foreign_key: true
      t.references :role, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :projects_users_roles, :deleted_at
    add_index :projects_users_roles, :active
    add_index :projects_users_roles, [:projects_user_id, :role_id, :deleted_at], name: 'index_pur_on_pu_id_r_id_deleted_at_uniq', unique: true
    add_index :projects_users_roles, [:projects_user_id, :role_id, :active],     name: 'index_pur_on_pu_id_r_id_active_uniq',     unique: true
  end
end
