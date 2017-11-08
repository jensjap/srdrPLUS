class CreateType1Types < ActiveRecord::Migration[5.0]
  def change
    create_table :type1_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :type1_types, :deleted_at
  end
end
