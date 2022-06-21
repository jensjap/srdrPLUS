class CreateAbstractScreeningResults < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screening_results do |t|
      t.references :abstract_screening
      t.references :abstract_screenings_projects_users_role, index: { name: 'asr_on_aspur' }
      t.references :abstract_screenings_citations_project, index: { name: 'asr_on_ascp' }
      t.integer :label, limit: 1, null: false
      t.timestamps
    end
  end
end
