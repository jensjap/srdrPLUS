class AddPositionToAbstractScreeningsReasonsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screenings_reasons_users, :position, :integer
  end
end
