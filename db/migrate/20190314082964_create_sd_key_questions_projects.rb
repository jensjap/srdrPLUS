class CreateSdKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :sd_key_questions_projects do |t|
      t.references :sd_key_question, foreign_key: true
      t.references :key_questions_project, foreign_key: true

      t.timestamps
    end
  end
end
