class AddUniqueConstraintToFulltextScreeningResults < ActiveRecord::Migration[7.0]
  def up
    duplicates = FulltextScreeningResult.select(:fulltext_screening_id, :user_id, :citations_project_id, :privileged)
                                        .group(:fulltext_screening_id, :user_id, :citations_project_id, :privileged)
                                        .having('COUNT(*) > 1')

    duplicates.each do |duplicate|
      FulltextScreeningResult.where(fulltext_screening_id: duplicate.fulltext_screening_id,
                                    user_id: duplicate.user_id,
                                    citations_project_id: duplicate.citations_project_id,
                                    privileged: duplicate.privileged)
                             .order(created_at: :asc)
                             .offset(1)
                             .destroy_all
    end

    add_index :fulltext_screening_results, [:fulltext_screening_id, :user_id, :citations_project_id, :privileged], unique: true, name: 'unique_fulltext_screening_results'
  end
  
  def down
    remove_index :fulltext_screening_results, name: 'unique_fulltext_screening_results'
  end
end
