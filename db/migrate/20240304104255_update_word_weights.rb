class UpdateWordWeights < ActiveRecord::Migration[7.0]
  def change
    add_foreign_key :word_weights, :projects, column: :project_id

    remove_index :word_weights, name: 'u_as_w'
    remove_column :word_weights, :user_id
    remove_column :word_weights, :abstract_screening_id

    add_index :word_weights,
              %i[project_id word],
              unique: true,
              name: 'project_id_word'
  end
end
