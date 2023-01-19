class AddPositionToFulltextScreeningsReasonsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screenings_reasons_users, :position, :integer
  end
end
