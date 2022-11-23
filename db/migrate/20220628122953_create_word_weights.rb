class CreateWordWeights < ActiveRecord::Migration[7.0]
  def change
    create_table :word_weights do |t|
      t.references :user, index: { name: 'ww_on_u' }
      t.references :abstract_screening, index: { name: 'ww_on_as' }
      t.integer :weight, limit: 1, null: false
      t.string :word, null: false
      t.timestamps
    end
    add_index :word_weights,
              %i[user_id abstract_screening_id word],
              unique: true,
              name: 'u_as_w'
  end
end
