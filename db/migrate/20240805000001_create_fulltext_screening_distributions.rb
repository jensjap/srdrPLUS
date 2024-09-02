class CreateFulltextScreeningDistributions < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screening_distributions do |t|
      t.bigint :fulltext_screening_id, null: false
      t.integer :user_id, null: false
      t.integer :citations_project_id, null: false
      t.timestamps
    end

    add_foreign_key :fulltext_screening_distributions, :fulltext_screenings
    add_foreign_key :fulltext_screening_distributions, :users
    add_foreign_key :fulltext_screening_distributions, :citations_projects
  end
end
