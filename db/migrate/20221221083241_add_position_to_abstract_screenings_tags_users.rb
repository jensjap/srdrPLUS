class AddPositionToAbstractScreeningsTagsUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :abstract_screenings_tags_users, :position, :integer
  end
end
