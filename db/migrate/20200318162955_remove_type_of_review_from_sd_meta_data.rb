class RemoveTypeOfReviewFromSdMetaData < ActiveRecord::Migration[5.2]
  def change
    remove_column :sd_meta_data, :type_of_review, :string
  end
end
