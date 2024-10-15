class AddCaseSensitiveToWordWeights < ActiveRecord::Migration[7.0]
  def change
    add_column :word_weights, :case_sensitive, :boolean, default: false, null: false
  end
end
