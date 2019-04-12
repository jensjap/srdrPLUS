class MakeKeyQuestionsLonger < ActiveRecord::Migration[5.0]
  def change
    remove_index :key_questions, :name
    change_column :key_questions, :name, :text
    add_index :key_questions, :name, unique: true, length: 255
  end
end
