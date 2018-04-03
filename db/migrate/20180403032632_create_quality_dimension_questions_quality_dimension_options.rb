class CreateQualityDimensionQuestionsQualityDimensionOptions < ActiveRecord::Migration[5.0]
  def change
    create_table :quality_dimension_questions_quality_dimension_options do |t|
      t.references :quality_dimension_question, foreign_key: true, index: { name: 'index_qdqqdo_on_qdq_id' }
      t.references :quality_dimension_option, foreign_key: true,   index: { name: 'index_qdqqdo_on_qdo_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :quality_dimension_questions_quality_dimension_options, [:quality_dimension_question_id, :quality_dimension_option_id, :active], name: 'index_qdq_id_qdo_id_active_uniq', unique: true
  end
end
