class AddTimingToPicods < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_picods, :timing, :text
  end
end
