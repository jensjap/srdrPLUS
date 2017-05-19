class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.references :question_type, foreign_key: true
      t.references :extraction_forms_projects_section, foreign_key: true
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :questions, :deleted_at
  end
end
