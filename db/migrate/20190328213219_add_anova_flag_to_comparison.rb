class AddAnovaFlagToComparison < ActiveRecord::Migration[5.0]
  def change
    add_column :comparisons, :is_anova, :boolean, null: false, default: false
  end
end
