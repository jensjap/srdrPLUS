class CreateProjectsUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :projects_users do |t|
      t.references :project, foreign_key: true
      t.references :user, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :projects_users, :deleted_at
    add_index :projects_users, :active
    add_index :projects_users, [:project_id, :user_id, :deleted_at], name: 'index_pu_on_p_id_u_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :projects_users, [:project_id, :user_id, :active],     name: 'index_pu_on_p_id_u_id_active_uniq',     unique: true
  end
end
