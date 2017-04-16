class CreateKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :key_questions_projects do |t|
      t.references :key_question, foreign_key: true
      t.references :project, foreign_key: true
      t.integer :position

      t.timestamps
    end
  end
end
