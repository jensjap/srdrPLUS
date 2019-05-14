class CreateKeyQuestionTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :key_question_types do |t|
      t.string :name

      t.timestamps
    end
  end
end
