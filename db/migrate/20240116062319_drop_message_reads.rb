class DropMessageReads < ActiveRecord::Migration[7.0]
  def change
    drop_table :message_reads
  end
end
