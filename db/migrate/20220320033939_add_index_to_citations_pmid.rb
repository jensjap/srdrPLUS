class AddIndexToCitationsPmid < ActiveRecord::Migration[5.2]
  def change
    add_index :citations, :pmid
  end
end
