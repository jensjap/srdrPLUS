class CreateFulltextScreeningResults < ActiveRecord::Migration[7.0]
  def change
    create_table :fulltext_screening_results do |t|
      t.references :fulltext_screening
      t.references :user, index: { name: 'fsr_on_u' }
      t.references :citations_project, index: { name: 'fsr_on_cp' }
      t.integer :label, limit: 1
      t.text :notes
      t.timestamps
    end
  end
end
