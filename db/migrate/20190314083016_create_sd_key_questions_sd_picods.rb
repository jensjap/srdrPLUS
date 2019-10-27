class CreateSdKeyQuestionsSdPicods < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_key_questions_sd_picods do |t|
      t.references :sd_key_question, foreign_key: true
      t.references :sd_picod, foreign_key: true

      t.timestamps
    end
  end
end
