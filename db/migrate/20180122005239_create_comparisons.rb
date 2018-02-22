class CreateComparisons < ActiveRecord::Migration[5.0]
  def change
    create_table :comparisons do |t|
      t.references :result_statistic_section,  foreign_key: true, index: { name: 'result_statistic_section_id' }
      t.timestamps
    end
  end
end
