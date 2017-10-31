class CreateExtractions < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions do |t|
      t.references :projects_study, foreign_key: true
      t.references :projects_users_role, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :extractions, :deleted_at
    add_index :extractions, [:projects_study_id, :projects_users_role_id, :deleted_at], name: 'index_e_on_ps_id_pur_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
  end
end
