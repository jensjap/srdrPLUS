class CreatePublishings < ActiveRecord::Migration[5.0]
  def change
    create_table :publishings do |t|
      t.references :publishable, polymorphic: true, index: true
      t.integer :requested_by_id, foreign_key: true
      t.integer :approved_by_id, foreign_key: true
      t.datetime :approved_at

      t.timestamps
    end

    add_index :publishings, :requested_by_id
    add_index :publishings, :approved_by_id
  end
end
