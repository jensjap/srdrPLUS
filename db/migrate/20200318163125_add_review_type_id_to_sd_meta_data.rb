class AddReviewTypeIdToSdMetaData < ActiveRecord::Migration[5.2]
  def change
    add_reference :sd_meta_data, :review_type, foreign_key: true
  end
end
