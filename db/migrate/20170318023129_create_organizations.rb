class CreateOrganizations < ActiveRecord::Migration[5.0]
  def change
    create_table :organizations do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :organizations, :name, unique: true
    add_index :organizations, :deleted_at
  end
end
