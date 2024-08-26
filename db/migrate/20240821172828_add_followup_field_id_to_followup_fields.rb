class AddFollowupFieldIdToFollowupFields < ActiveRecord::Migration[7.0]
  def change
    add_reference :followup_fields, :followup_field, null: true, foreign_key: true, type: :bigint, index: { name: 'index_ffs_on_followup_field_id' }
  end
end
