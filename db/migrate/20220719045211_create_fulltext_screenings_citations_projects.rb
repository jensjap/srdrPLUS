class CreateFulltextScreeningsCitationsProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screenings_citations_projects do |t|
      t.references :fulltext_screening, null: false, type: :bigint, index: { name: 'ftscp_on_fts' }
      t.references :citations_project, null: false, type: :bigint, index: { name: 'ftscp_on_cp' }
      t.timestamps
    end
    add_index :fulltext_screenings_citations_projects,
              %i[citations_project_id fulltext_screening_id],
              unique: true,
              name: 'cp_id_on_fts_id'
  end
end
