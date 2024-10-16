class AddReasonToLogs < ActiveRecord::Migration[7.0]
  def change
    add_column :logs, :reason, :string
  end
end
