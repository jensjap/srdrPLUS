class CreateWordGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :word_groups do |t|
      t.string :name, null: false
      t.string :color
      t.bigint :project_id, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :word_weights, :word_group, foreign_key: true
  end
end
