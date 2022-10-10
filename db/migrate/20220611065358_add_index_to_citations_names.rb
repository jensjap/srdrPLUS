class AddIndexToCitationsNames < ActiveRecord::Migration[5.2]
  def change
    add_index :citations, :name
  end
end
