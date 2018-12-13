class AddDefaultToResultStatisticSectionTypesMeasure < ActiveRecord::Migration[5.0]
  def change
    add_column :result_statistic_section_types_measures, :default, :boolean, default: false
  end
end
