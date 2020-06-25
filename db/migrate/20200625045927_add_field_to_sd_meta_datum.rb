class AddFieldToSdMetaDatum < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_meta_data, :section_flag_8, :boolean, default: false, null: false
  end
end
