class CreateSdKeyQuestionsKeyQuestionTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :sd_key_questions_key_question_types do |t|
      t.references :sd_key_question, index: { name: :index_sd_kqs }
      t.references :key_question_type, index: { name: :index_kq_types }

      t.timestamps
    end

    add_index :sd_key_questions_key_question_types, [:sd_key_question_id, :key_question_type_id], name: 'index_sd_kqs_kq_types'
  end
end
