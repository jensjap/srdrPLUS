class CreateWordWeights < ActiveRecord::Migration[7.0]
  def change
    create_table :word_weights do |t|
      t.references :abstract_screenings_projects_users_role, index: { name: 'asr_on_aspur' }
      t.integer :weight, limit: 1, null: false
      t.string :word, null: false
      t.timestamps
    end
    add_index :word_weights, %i[abstract_screenings_projects_users_role_id word], unique: true,
                                                                                  name: 'aspur_w'
  end
end
