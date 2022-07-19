class CreateFulltextScreeningResults < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screening_results do |t|
      t.references :fulltext_screening
      t.references :fulltext_screenings_projects_users_role, index: { name: 'ftsr_on_ftspur' }
      t.references :fulltext_screenings_citations_project, index: { name: 'ftsr_on_ftscp' }
      t.integer :label, limit: 1
      t.timestamps
    end
  end
end
