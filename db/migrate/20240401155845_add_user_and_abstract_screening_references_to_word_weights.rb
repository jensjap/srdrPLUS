class AddUserAndAbstractScreeningReferencesToWordWeights < ActiveRecord::Migration[7.0]
  def change
    add_reference :word_weights, :user, null: false, foreign_key: true, type: :integer, default: 1
    add_reference :word_weights, :abstract_screening, null: false, foreign_key: true, type: :bigint, default: 1
  end
end
