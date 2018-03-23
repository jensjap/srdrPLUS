class CreateExtractions < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions do |t|
      t.references :citations_project, foreign_key: true
      t.references :projects_users_role, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extractions, :deleted_at
    add_index :extractions, [:citations_project_id, :projects_users_role_id, :deleted_at], name: 'index_e_on_cp_id_pur_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
  end
end
