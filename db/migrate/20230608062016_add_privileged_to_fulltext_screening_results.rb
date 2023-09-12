class AddPrivilegedToFulltextScreeningResults < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screening_results, :privileged, :boolean, default: false
  end
end
