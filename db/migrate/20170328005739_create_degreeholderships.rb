class CreateDegreeholderships < ActiveRecord::Migration[5.0]
  def change
    create_table :degreeholderships do |t|
      t.references :degree, foreign_key: true
      t.references :profile, foreign_key: true
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :degreeholderships, [:degree_id, :profile_id], where: 'deleted_at IS NULL'
    add_index :degreeholderships, [:degree_id, :profile_id, :active], unique: true
  end
end

