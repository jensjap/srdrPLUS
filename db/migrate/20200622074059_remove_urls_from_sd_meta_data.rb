class RemoveUrlsFromSdMetaData < ActiveRecord::Migration[5.2]
  def change
    remove_column :sd_meta_data, :evs_introduction_link, :text
    remove_column :sd_meta_data, :evs_methods_link, :text
    remove_column :sd_meta_data, :evs_results_link, :text
    remove_column :sd_meta_data, :evs_discussion_link, :text
    remove_column :sd_meta_data, :evs_conclusions_link, :text
    remove_column :sd_meta_data, :evs_tables_figures_link, :text
  end
end
