class CreateWordWeights < ActiveRecord::Migration[7.0]
  def change
    create_table :word_weights do |t|
      t.references :user, index: { name: 'asr_on_u' }
      t.integer :weight, limit: 1, null: false
      t.string :word, null: false
      t.timestamps
    end
    add_index :word_weights, %i[user_id word], unique: true,
                                               name: 'u_w'
  end
end
