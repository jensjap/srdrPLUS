class CreateDegreesProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :degrees_profiles do |t|
      t.references :degree, foreign_key: true
      t.references :profile, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :degrees_profiles, :deleted_at
    add_index :degrees_profiles, :active
    add_index :degrees_profiles, [:degree_id, :profile_id, :deleted_at], name: 'index_dp_on_d_id_p_id_deleted_at_uniq', unique: true, where: 'deleted_at IS NULL'
    add_index :degrees_profiles, [:degree_id, :profile_id, :active],     name: 'index_dp_on_d_id_p_id_active_uniq',     unique: true
  end
end

