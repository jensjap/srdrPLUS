class CreateResultStatisticSectionTypes < ActiveRecord::Migration[5.0]
  def change
    create_table :result_statistic_section_types do |t|
      t.string :name
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :result_statistic_section_types, :deleted_at
  end
end
