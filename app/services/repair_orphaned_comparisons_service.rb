class RepairOrphanedComparisonsService
  def self.run
    remove_orphaned_net_comparisons
  end

  private

  def self.remove_orphaned_net_comparisons
    orphaned_record_ids = Set.new
    WacsBacsRssm.includes(:wac, :bac).all.each do |record|
      if record.wac.nil?
        puts "WacsBacsRssm with ID #{record.id} is orphaned.\nWAC type comparison with ID #{record.wac_id} is missing."
        orphaned_record_ids.add(record.id)
        record.destroy
      end
      if record.bac.nil?
        puts "WacsBacsRssm with ID #{record.id} is orphaned.\nBAC type comparison with ID #{record.bac_id} is missing."
        orphaned_record_ids.add(record.id)
        record.destroy
      end
    end

    puts "Found and destroyed #{orphaned_record_ids.size} WacsBacsRssm orphaned records."
  end
end