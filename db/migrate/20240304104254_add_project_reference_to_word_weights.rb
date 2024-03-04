class AddProjectReferenceToWordWeights < ActiveRecord::Migration[7.0]
  def change
    add_reference :word_weights, :project, type: :int
  end
end
