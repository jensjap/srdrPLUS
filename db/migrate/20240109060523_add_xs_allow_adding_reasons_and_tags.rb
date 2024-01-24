class AddXsAllowAddingReasonsAndTags < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :as_allow_adding_reasons, :boolean, default: true, null: false
    add_column :projects, :as_allow_adding_tags, :boolean, default: true, null: false
    add_column :projects, :fs_allow_adding_reasons, :boolean, default: true, null: false
    add_column :projects, :fs_allow_adding_tags, :boolean, default: true, null: false
  end
end
