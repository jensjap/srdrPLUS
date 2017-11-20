class ChangeLabelValueToString < ActiveRecord::Migration[5.0]
  def change
    change_column :labels, :value, :string
  end
end
