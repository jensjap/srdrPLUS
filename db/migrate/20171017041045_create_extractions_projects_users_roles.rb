class CreateExtractionsProjectsUsersRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions_projects_users_roles do |t|
      t.references :extraction,          foreign_key: true, index: { name: 'index_epur_on_e_id' }
      t.references :projects_users_role, foreign_key: true, index: { name: 'index_epur_on_pur_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extractions_projects_users_roles, :deleted_at, name: 'index_epur_on_deleted_at'
    add_index :extractions_projects_users_roles, :active,     name: 'index_epur_on_active'
    add_index :extractions_projects_users_roles, [:extraction_id, :projects_users_role_id, :deleted_at], name: 'index_epur_on_e_id_pur_id_deleted_at_uniq', unique: true
    add_index :extractions_projects_users_roles, [:extraction_id, :projects_users_role_id, :active],     name: 'index_epur_on_e_id_pur_id_active_uniq',     unique: true
  end
end
