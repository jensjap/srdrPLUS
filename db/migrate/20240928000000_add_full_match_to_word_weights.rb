class AddFullMatchToWordWeights < ActiveRecord::Migration[7.0]
  def change
    add_column :word_weights, :full_match, :boolean, default: false, null: false
  end
end
