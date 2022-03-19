class DropStudies < ActiveRecord::Migration[5.2]
  def change
    drop_table :studies
  end
end
