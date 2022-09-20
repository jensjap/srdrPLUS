class CreateSfAbstractRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :sf_abstract_records do |t|
      t.references :sf_cell
      t.references :abstract_screening_result
      t.timestamps
    end
  end
end
