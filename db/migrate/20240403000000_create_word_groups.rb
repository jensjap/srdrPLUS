class CreateWordGroups < ActiveRecord::Migration[7.0]
  def change
    create_table :word_groups do |t|
      t.string :name, null: false
      t.string :color
      t.bigint :abstract_screening_id, null: false, foreign_key: true
      t.bigint :user_id, null: false, foreign_key: true

      t.timestamps
    end

    add_reference :word_weights, :word_group, foreign_key: true
    add_column :word_groups, :case_sensitive, :boolean, default: false
  end
end
