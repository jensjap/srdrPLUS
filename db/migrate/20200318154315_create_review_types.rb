class CreateReviewTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :review_types do |t|
      t.string :name
      t.timestamps
    end
  end
end
