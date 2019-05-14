class CreateSdKeyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_key_questions do |t|
      t.references :sd_meta_datum, foreign_key: true
      t.references :sd_key_question, foreign_key: true
      t.references :key_question, foreign_key: true

      t.timestamps
    end
  end
end
