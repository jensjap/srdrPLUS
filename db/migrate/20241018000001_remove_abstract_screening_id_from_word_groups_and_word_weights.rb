class RemoveAbstractScreeningIdFromWordGroupsAndWordWeights < ActiveRecord::Migration[7.0]
  def up

    duplicate_records = WordWeight.select('user_id, project_id, word, COUNT(*) as count')
                                  .group('user_id, project_id, word')
                                  .having('COUNT(*) > 1')

    duplicate_records.each do |record|
      duplicates = WordWeight.where(user_id: record.user_id, project_id: record.project_id, word: record.word)
      duplicates.offset(1).destroy_all
    end

    remove_index :word_weights, name: 'u_as_w'

    add_index :word_weights, [:user_id, :project_id, :word], unique: true, name: 'index_word_weights_on_user_group_word'

    if foreign_key_exists?(:word_weights, :abstract_screenings)
      remove_foreign_key :word_weights, :abstract_screenings
    end

    if index_exists?(:word_weights, :abstract_screening_id)
      remove_index :word_weights, :abstract_screening_id
    end

    if column_exists?(:word_weights, :abstract_screening_id)
      remove_column :word_weights, :abstract_screening_id
    end

    if foreign_key_exists?(:word_groups, :abstract_screenings)
      remove_foreign_key :word_groups, :abstract_screenings
    end

    if index_exists?(:word_groups, :abstract_screening_id)
      remove_index :word_groups, :abstract_screening_id
    end

    if column_exists?(:word_groups, :abstract_screening_id)
      remove_column :word_groups, :abstract_screening_id
    end

  end

  def down
    add_reference :word_weights, :abstract_screening, foreign_key: true, null: true
    add_reference :word_groups, :abstract_screening, foreign_key: true, null: true

    remove_index :word_weights, name: 'index_word_weights_on_user_group_word'
  end
end
