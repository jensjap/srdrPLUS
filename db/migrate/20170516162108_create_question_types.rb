class CreateQuestionTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :question_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :question_types, :deleted_at
  end
end
