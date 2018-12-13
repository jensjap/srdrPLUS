class AddType1TypeToResultStatisticSectionTypesMeasure < ActiveRecord::Migration[5.0]
  def change
    add_reference :result_statistic_section_types_measures, :type1_type, foreign_key: true
  end
end
