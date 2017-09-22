class CreatePriorities < ActiveRecord::Migration[5.0]
  def change
    create_table :priorities do |t|
      t.references :citations_project, foreign_key: true
      t.integer :value
      t.integer :num_times_labeled

      t.timestamps
    end
  end
end
