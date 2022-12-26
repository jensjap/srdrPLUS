class AddPositionToFulltextScreeningsTagsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :fulltext_screenings_tags_users, :position, :integer
  end
end
