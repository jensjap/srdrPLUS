# 1 run migration
# 2 run "ConsolidateWordWeightsService.run_all!"
# 3 remove prefix . from .20240304104255_update_word_weights.rb
# 4 run migration
# 5 delete all lines commented with "# TO DO: DELETE AFTER MIGRATING"

class ConsolidateWordWeightsService
  def self.run_all!
    populate_project_ids
    backup
    prune_orphans_and_duplicates
  end

  def self.populate_project_ids
    ww_groups = WordWeight.joins(:abstract_screening).includes(:abstract_screening).group_by do |a|
      a.abstract_screening.project_id
    end

    ww_groups.each do |project_id, ww_group|
      WordWeight.where(id: ww_group.map(&:id)).update_all(project_id:)
    end
  end

  def self.backup
    CSV.open("word_weights-#{Time.now}.csv", 'wb') do |csv|
      csv << WordWeight.attribute_names
      WordWeight.in_batches do |batch|
        batch.each do |ww|
          csv << ww.attributes.values
        end
      end
    end
  end

  def self.prune_orphans_and_duplicates
    WordWeight.where(project_id: nil).delete_all

    unique_ww_ids = WordWeight.select('MAX(id) as id').group(:word, :project_id).map(&:id)
    duplicate_word_weights = WordWeight.where.not(id: unique_ww_ids)

    duplicate_word_weights.in_batches(&:delete_all)
  end
end
