class CreateCitationsProjectsFulltextScreenings < ActiveRecord::Migration[7.0]
  def change
    create_table :citations_projects_fulltext_screenings do |t|
      t.references :fulltext_screening, null: false, type: :bigint, index: { name: 'cpfts_on_fts' }
      t.references :citations_project, null: false, type: :bigint, index: { name: 'cpfts_on_cp' }
      t.timestamps
    end
    add_index :citations_projects_fulltext_screenings,
              %i[citations_project_id fulltext_screening_id],
              unique: true,
              name: 'cp_id_on_fts_id'
  end
end
