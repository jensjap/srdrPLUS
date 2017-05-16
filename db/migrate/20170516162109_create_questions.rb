class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :questions, :deleted_at
  end
end
