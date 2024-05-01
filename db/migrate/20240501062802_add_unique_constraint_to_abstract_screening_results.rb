class AddUniqueConstraintToAbstractScreeningResults < ActiveRecord::Migration[7.0]
  def up
    duplicates = AbstractScreeningResult.select(:abstract_screening_id, :user_id, :citations_project_id, :privileged)
                                        .group(:abstract_screening_id, :user_id, :citations_project_id, :privileged)
                                        .having('COUNT(*) > 1')

    duplicates.each do |duplicate|
      AbstractScreeningResult.where(abstract_screening_id: duplicate.abstract_screening_id,
                                    user_id: duplicate.user_id,
                                    citations_project_id: duplicate.citations_project_id,
                                    privileged: duplicate.privileged)
                             .order(created_at: :asc)
                             .offset(1)
                             .destroy_all
    end

    add_index :abstract_screening_results, [:abstract_screening_id, :user_id, :citations_project_id, :privileged], unique: true, name: 'unique_abstract_screening_results'
  end
  
  def down
    remove_index :abstract_screening_results, name: 'unique_abstract_screening_results'
  end
end
