class AddUniqIndexToDegree < ActiveRecord::Migration[5.0]
  def change
    add_index :degrees, :name, unique: true
  end
end
