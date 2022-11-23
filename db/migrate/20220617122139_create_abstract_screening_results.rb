class CreateAbstractScreeningResults < ActiveRecord::Migration[7.0]
  def change
    create_table :abstract_screening_results do |t|
      t.references :abstract_screening
      t.references :user, index: { name: 'asr_on_u' }
      t.references :citations_project, index: { name: 'asr_on_cp' }
      t.integer :label, limit: 1
      t.text :notes
      t.timestamps
    end
  end
end
