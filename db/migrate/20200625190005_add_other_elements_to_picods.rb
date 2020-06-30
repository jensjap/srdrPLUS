class AddOtherElementsToPicods < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_picods, :other_elements, :text
  end
end
