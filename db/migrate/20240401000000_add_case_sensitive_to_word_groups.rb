class AddCaseSensitiveToWordGroups < ActiveRecord::Migration[7.0]
  def change
    add_column :word_groups, :case_sensitive, :boolean, default: false
  end
end
