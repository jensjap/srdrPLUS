class CreateExtractionsKeyQuestionsProjects < ActiveRecord::Migration[5.0]
  def change
    create_table :extractions_key_questions_projects do |t|
      t.references :extraction,            foreign_key: true, index: { name: 'index_ekqp_on_e_id' }
      t.references :key_questions_project, foreign_key: true, index: { name: 'index_ekqp_on_kqp_id' }
      t.datetime :deleted_at
      t.boolean :active

      t.timestamps
    end

    add_index :extractions_key_questions_projects, :deleted_at, name: 'index_ekqp_on_deleted_at'
    add_index :extractions_key_questions_projects, :active,     name: 'index_ekqp_on_active'
    add_index :extractions_key_questions_projects, [:extraction_id, :key_questions_project_id, :deleted_at], name: 'index_ekqp_on_e_id_kqp_id_deleted_at', where: 'deleted_at IS NULL'
    add_index :extractions_key_questions_projects, [:extraction_id, :key_questions_project_id, :active]    , name: 'index_ekqp_on_e_id_kqp_id_active'
  end
end
