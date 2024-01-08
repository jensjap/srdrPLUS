class CreateMbReads < ActiveRecord::Migration[7.0]
  def change
    create_table :mb_reads do |t|
      t.references :user, null: false
      t.references :mb_message, null: false

      t.timestamps
    end

    add_index :mb_reads, %i[user_id mb_message_id], unique: true
  end
end
