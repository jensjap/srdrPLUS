class CreateKeyQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :key_questions do |t|
      t.text :name

      t.timestamps
    end
  end
end
