class RemoveXsReasonsTags < ActiveRecord::Migration[7.0]
  def change
    remove_column :projects, :as_reasons_tags
    remove_column :projects, :fs_reasons_tags
  end
end
