class CreateSfQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :sf_questions do |t|
      t.references :screening_form
      t.string :name, null: false
      t.text :description
      t.integer :position
      t.timestamps
    end
  end
end
