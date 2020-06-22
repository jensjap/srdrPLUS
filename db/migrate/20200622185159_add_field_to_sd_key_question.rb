class AddFieldToSdKeyQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :sd_key_questions, :includes_meta_analysis, :boolean
  end
end
