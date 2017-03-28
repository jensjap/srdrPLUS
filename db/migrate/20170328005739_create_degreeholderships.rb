class CreateDegreeholderships < ActiveRecord::Migration[5.0]
  def change
    create_table :degreeholderships do |t|
      t.references :degree, foreign_key: true
      t.references :profile, foreign_key: true
      t.datetime :deleted_at

      t.timestamps
    end
    add_index :degreeholderships, :deleted_at
    add_index :degreeholderships, [:degree_id, :profile_id], where: 'deleted_at IS NULL'
    # This doesn't work with MySQL (https://github.com/rubysherpas/paranoia)
    #add_index :degreeholderships, [:degree_id, :profile_id, 'COALESCE(deleted_at, false)'], unique: true, name: 'unique_non_deleted_degreeholderships'
  end
end
