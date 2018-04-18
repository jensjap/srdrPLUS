class CreateComparisonsMeasures < ActiveRecord::Migration[5.0]
  def change
    create_table :comparisons_measures do |t|
      t.references :measure, foreign_key: true
      t.references :comparison, foreign_key: true
      t.timestamps
    end
  end
end
