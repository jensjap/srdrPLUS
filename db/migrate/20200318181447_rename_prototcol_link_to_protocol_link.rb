class RenamePrototcolLinkToProtocolLink < ActiveRecord::Migration[5.2]
  def change
    rename_column :sd_meta_data, :prototcol_link, :protocol_link
  end
end
