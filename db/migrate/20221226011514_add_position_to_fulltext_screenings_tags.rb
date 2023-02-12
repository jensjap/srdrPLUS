class AddPositionToFulltextScreeningsTags < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screenings_tags, :position, :integer
  end
end
