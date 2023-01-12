class AddPositionToFulltextScreeningsReasons < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screenings_reasons, :position, :integer
  end
end
