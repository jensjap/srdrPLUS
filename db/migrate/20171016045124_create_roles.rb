class CreateRoles < ActiveRecord::Migration[5.0]
  def change
    create_table :roles do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :roles, :name, unique: true
    add_index :roles, :deleted_at
  end
end
