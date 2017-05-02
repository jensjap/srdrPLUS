class CreateProfiles < ActiveRecord::Migration[5.0]
  def change
    create_table :profiles do |t|
      t.references :user, foreign_key: true
      t.references :organization, foreign_key: true
      t.string :time_zone, default: "UTC"
      t.string :username
      t.string :first_name
      t.string :middle_name
      t.string :last_name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :profiles, :username, unique: true
    remove_foreign_key :profiles, :users
    remove_index :profiles, :user_id
    add_index :profiles, :user_id, unique: true
    add_foreign_key :profiles, :users
    add_index :profiles, :deleted_at
  end
end
