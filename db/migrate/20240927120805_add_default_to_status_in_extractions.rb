class AddDefaultToStatusInExtractions < ActiveRecord::Migration[7.0]
  def change
    change_column :extractions, :status, :string, :default => 'awaiting_work'
  end
end
