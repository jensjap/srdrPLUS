class CreateQualityDimensionQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :quality_dimension_questions do |t|
      t.references :quality_dimension_section, foreign_key: true, index: { name: 'index_qdq_on_qds_id' }
      t.string :name
      t.text :description
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :quality_dimension_questions, :deleted_at
  end
end
