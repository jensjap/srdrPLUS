class CreateDataAnalysisLevels < ActiveRecord::Migration[5.2]
  def change
    create_table :data_analysis_levels do |t|
      t.string :name
      t.timestamps
    end
  end
end
