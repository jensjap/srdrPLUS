class AddSectionCompletenessFlagsToSdMetaData < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_meta_data, :section_flag_0, :boolean, default: false, null: false
    add_column :sd_meta_data, :section_flag_1, :boolean, default: false, null: false
    add_column :sd_meta_data, :section_flag_2, :boolean, default: false, null: false
    add_column :sd_meta_data, :section_flag_3, :boolean, default: false, null: false
    add_column :sd_meta_data, :section_flag_4, :boolean, default: false, null: false
    add_column :sd_meta_data, :section_flag_5, :boolean, default: false, null: false
  end
end
