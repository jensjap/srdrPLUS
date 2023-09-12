class AddPrivilegedToAbstractScreeningResults < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screening_results, :privileged, :boolean, default: false
  end
end
