class DedupeCitationsJob < ApplicationJob
  queue_as :default

  def perform(*args)
    project_id = args.first
    Rails.logger.info "#{self.class.name}: Starting deduplication for project #{project_id}"

    @project = Project.includes(
      citations_projects: %i[
        extractions abstract_screening_results fulltext_screening_results
        screening_qualifications ml_predictions logs citation
      ]
    ).find(project_id)

    raise ArgumentError, "Project #{project_id} not found" unless @project

    start_time = Time.current
    citations_projects_processed = 0
    citations_processed = 0

    begin
      ActiveRecord::Base.transaction do
        citations_projects_processed = dedupe_citations_projects(@project)
        citations_processed = dedupe_citations(@project)
      end

      duration = Time.current - start_time
      Rails.logger.info "#{self.class.name}: Completed for project #{project_id} in #{duration.round(2)}s. Processed #{citations_projects_processed} CitationsProject groups and #{citations_processed} Citation groups"
    rescue ActiveRecord::RecordNotFound => e
      Rails.logger.error "#{self.class.name}: Record not found - #{e.message}"
      report_sentry(e)
      raise
    rescue ActiveRecord::StatementInvalid => e
      Rails.logger.error "#{self.class.name}: Database error - #{e.message}"
      report_sentry(e)
      raise ActiveRecord::Rollback
    rescue StandardError => e
      Rails.logger.error "#{self.class.name}: Unexpected error - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      report_sentry(e)
      raise ActiveRecord::Rollback
    end
  end

  def dedupe_citations_projects(project)
    return 0 if project.citations_projects.empty?

    duplicate_groups = project.citations_projects
                              .group_by(&:citation_id)
                              .select { |_, cps| cps.size > 1 }

    return 0 if duplicate_groups.empty?

    Rails.logger.info "Found #{duplicate_groups.size} CitationsProject duplicate groups to process"
    processed_count = 0

    duplicate_groups.each do |citation_id, lsof_cp|
      next if lsof_cp.blank?

      Rails.logger.debug "Processing #{lsof_cp.size} duplicates for citation #{citation_id}"

      # Destroy duplicates with no associations first (bulk operation)
      unassociated = lsof_cp.select { |cp| associations_empty?(cp) }
      if unassociated.size > 1
        # Keep one, destroy the rest
        to_destroy = unassociated[1..-1]
        destroyed_ids = to_destroy.map(&:id)
        CitationsProject.where(id: destroyed_ids).delete_all
        Rails.logger.debug "Bulk destroyed #{to_destroy.size} unassociated CitationsProjects: #{destroyed_ids}"
        lsof_cp -= to_destroy
      end

      next unless lsof_cp.size > 1

      # Find master (prioritize most advanced screening_status, then association count)
      master_cp = select_master_by_status(lsof_cp)
      duplicates_to_merge = lsof_cp - [master_cp]

      Rails.logger.debug "Master CP: #{master_cp.id} (status: #{master_cp.screening_status}), merging #{duplicates_to_merge.size} duplicates"

      # Merge metadata from duplicates before transferring associations
      merge_metadata(master_cp, duplicates_to_merge)

      duplicates_to_merge.each do |cp|
        transfer_all_associations(master_cp, cp)
        reload_associations_safely(cp)
        Rails.logger.debug "Destroying duplicate CitationsProject #{cp.id} after transferring associations"
        cp.destroy!
      rescue ActiveRecord::RecordNotDestroyed => e
        Rails.logger.error "Failed to destroy CitationsProject #{cp.id}: #{e.message}"
        report_sentry(e)
      rescue StandardError => e
        Rails.logger.error "Error processing CitationsProject #{cp.id}: #{e.message}"
        report_sentry(e)
      end

      reload_associations_safely(master_cp)
      master_cp.reindex
      processed_count += 1
    end

    processed_count
  end

  # Modularized: Deduplicate Citation records
  def dedupe_citations(project)
    return 0 if project.citations.empty?

    # Find duplicates by grouping citations (case-insensitive to match MySQL GROUP BY behavior)
    duplicate_citation_groups = project.citations
                                       .group_by { |c| [c.citation_type_id, c.name&.downcase, c.pmid, c.abstract&.downcase] }
                                       .select { |_, citations| citations.size > 1 }

    return 0 if duplicate_citation_groups.empty?

    Rails.logger.info "Found #{duplicate_citation_groups.size} Citation duplicate groups to process"
    processed_count = 0

    duplicate_citation_groups.each do |signature, group|
      next if group.blank? || group.size < 2

      Rails.logger.debug "Processing #{group.size} duplicate citations with signature: #{signature.inspect}"

      master_citation = group.first
      duplicate_citations = group[1..-1]

      duplicate_citations.each do |duplicate_citation|
        master_cp = project.citations_projects.find_by(citation_id: master_citation.id)
        cp_to_remove = project.citations_projects.find_by(citation_id: duplicate_citation.id)

        # Transfer associations and destroy cp_to_remove if both exist in current project
        if master_cp && cp_to_remove
          transfer_all_associations(master_cp, cp_to_remove)
          reload_associations_safely(cp_to_remove)
          Rails.logger.debug "Destroying CitationsProject #{cp_to_remove.id} (citation #{duplicate_citation.id}) in current project"
          cp_to_remove.destroy!
        elsif cp_to_remove.nil?
          Rails.logger.debug "CitationsProject not found for citation #{duplicate_citation.id} in project #{project.id} (may have been removed during CitationsProject dedup)"
        elsif master_cp.nil?
          Rails.logger.warn "Master CitationsProject not found for citation #{master_citation.id} in project #{project.id}"
        end

        # Update ALL CitationsProject records (in OTHER projects only) to point to master Citation
        # This must happen BEFORE destroying the duplicate Citation to prevent cascading deletion
        other_project_cps = CitationsProject.where(citation_id: duplicate_citation.id).where.not(project_id: project.id)
        duplicate_cp_count = other_project_cps.count
        if duplicate_cp_count > 0
          Rails.logger.debug "Updating #{duplicate_cp_count} CitationsProject records (in other projects) to point to master Citation #{master_citation.id}"
          other_project_cps.update_all(citation_id: master_citation.id)
        end

        # Reload citations_projects and their associations to avoid stale data before destroying
        duplicate_citation.association(:citations_projects).reload
        duplicate_citation.citations_projects.each { |cp| reload_associations_safely(cp) }
        Rails.logger.debug "Destroying duplicate Citation #{duplicate_citation.id}"
        duplicate_citation.destroy!
      rescue ActiveRecord::RecordNotDestroyed => e
        Rails.logger.error "Failed to destroy Citation #{duplicate_citation.id}: #{e.message}"
        report_sentry(e)
      rescue StandardError => e
        Rails.logger.error "Error processing Citation #{duplicate_citation.id}: #{e.message}"
        report_sentry(e)
      end

      master_citation.association(:citations_projects).reload
      master_citation.citations_projects.each(&:reindex)
      processed_count += 1
    end

    processed_count
  end

  # Modularized: Transfer all associations from cp_to_remove to master_cp
  def transfer_all_associations(master_cp, cp_to_remove)
    transfer_association_records(master_cp, cp_to_remove, :extractions, Extraction)
    transfer_association_records(master_cp, cp_to_remove, :abstract_screening_results, AbstractScreeningResult)
    transfer_association_records(master_cp, cp_to_remove, :fulltext_screening_results, FulltextScreeningResult)
    transfer_association_records(master_cp, cp_to_remove, :screening_qualifications, ScreeningQualification)
    transfer_association_records(master_cp, cp_to_remove, :ml_predictions, MlPrediction)
    transfer_logs(master_cp, cp_to_remove)
  end

  # Helper method to safely reload associations
  def reload_associations_safely(cp)
    return unless cp.persisted?

    associations_to_reload = %i[extractions abstract_screening_results fulltext_screening_results
                                screening_qualifications ml_predictions logs]

    associations_to_reload.each do |assoc|
      cp.association(assoc).reload if cp.association(assoc).loaded?
    rescue StandardError => e
      Rails.logger.warn "Failed to reload #{assoc} for CP #{cp.id}: #{e.message}"
    end
  end

  def transfer_association_records(master_cp, cp_to_remove, assoc_name, model_class)
    # Use unscoped query to get ALL records, including those filtered by default scopes
    # This is important for Extraction model which has a default_scope filtering rejected citations
    begin
      updated_count = model_class.unscoped.where(citations_project_id: cp_to_remove.id).update_all(citations_project_id: master_cp.id)
      Rails.logger.debug "Transferred #{updated_count} #{assoc_name} from CP #{cp_to_remove.id} to #{master_cp.id}" if updated_count > 0
    rescue StandardError => e
      Rails.logger.error "Failed to bulk transfer #{assoc_name}: #{e.message}"
      report_sentry(e)
      # Fallback to individual updates using unscoped query
      model_class.unscoped.where(citations_project_id: cp_to_remove.id).find_each do |record|
        record.update_column(:citations_project_id, master_cp.id)
      rescue StandardError => e2
        Rails.logger.error "Failed to transfer #{assoc_name.to_s.singularize} #{record.id}: #{e2.message}"
        report_sentry(e2)
      end
    end
  end

  def transfer_logs(master_cp, cp_to_remove)
    return if cp_to_remove.logs.empty?

    log_ids = cp_to_remove.logs.where(loggable_type: 'CitationsProject').pluck(:id)
    return if log_ids.empty?

    updated_count = Log.where(id: log_ids)
                       .update_all(loggable_id: master_cp.id, loggable_type: master_cp.class.name)
    Rails.logger.debug "Transferred #{updated_count} logs"
  rescue StandardError => e
    Rails.logger.error "Failed to bulk transfer logs: #{e.message}"
    report_sentry(e)

    # Fallback to individual updates
    cp_to_remove.logs.each do |log|
      next unless log.loggable_type == 'CitationsProject'

      log.update_columns(loggable_id: master_cp.id, loggable_type: master_cp.class.name)
    rescue StandardError => e2
      Rails.logger.error "Failed to transfer log #{log.id}: #{e2.message}"
      report_sentry(e2)
    end
  end

  # Helper: check if CitationsProject has no associations (optimized with counts)
  def associations_empty?(cp)
    return false unless cp.persisted?

    # Use unscoped queries for extractions to include those filtered by default scope
    extraction_count = Extraction.unscoped.where(citations_project_id: cp.id).count
    return false if extraction_count > 0

    asr_count = cp.association(:abstract_screening_results).loaded? ? cp.abstract_screening_results.size : cp.abstract_screening_results.count
    return false if asr_count > 0

    fsr_count = cp.association(:fulltext_screening_results).loaded? ? cp.fulltext_screening_results.size : cp.fulltext_screening_results.count
    return false if fsr_count > 0

    sq_count = cp.association(:screening_qualifications).loaded? ? cp.screening_qualifications.size : cp.screening_qualifications.count
    return false if sq_count > 0

    ml_count = cp.association(:ml_predictions).loaded? ? cp.ml_predictions.size : cp.ml_predictions.count
    return false if ml_count > 0

    log_count = cp.association(:logs).loaded? ? cp.logs.size : cp.logs.count
    log_count == 0
  end

  # Helper: count total associations (optimized)
  def association_count(cp)
    return 0 unless cp.persisted?

    # Use unscoped query for extractions to include those filtered by default scope
    counts = {
      extractions: Extraction.unscoped.where(citations_project_id: cp.id).count,
      abstract_screening_results: cp.association(:abstract_screening_results).loaded? ? cp.abstract_screening_results.size : cp.abstract_screening_results.count,
      fulltext_screening_results: cp.association(:fulltext_screening_results).loaded? ? cp.fulltext_screening_results.size : cp.fulltext_screening_results.count,
      screening_qualifications: cp.association(:screening_qualifications).loaded? ? cp.screening_qualifications.size : cp.screening_qualifications.count,
      ml_predictions: cp.association(:ml_predictions).loaded? ? cp.ml_predictions.size : cp.ml_predictions.count,
      logs: cp.association(:logs).loaded? ? cp.logs.size : cp.logs.count
    }

    total = counts.values.sum
    Rails.logger.debug "CP #{cp.id} association counts: #{counts.inspect} (total: #{total})"
    total
  end

  # Merge metadata from duplicates into the master CitationsProject
  # Preserves pilot_flag, refman, and other_reference where applicable
  def merge_metadata(master_cp, duplicates)
    return if duplicates.empty?

    metadata_changed = false

    # Merge pilot_flag: Set to true if ANY duplicate (or master) has it as true
    if !master_cp.pilot_flag && duplicates.any?(&:pilot_flag)
      master_cp.pilot_flag = true
      metadata_changed = true
      Rails.logger.debug "Merged pilot_flag to true from duplicates"
    end

    # Merge refman: Use non-empty value, prefer master if both have data
    if master_cp.refman.blank?
      non_empty_refman = duplicates.find { |cp| cp.refman.present? }&.refman
      if non_empty_refman.present?
        master_cp.refman = non_empty_refman
        metadata_changed = true
        Rails.logger.debug "Merged refman from duplicate"
      end
    end

    # Merge other_reference: Combine unique non-empty values
    all_references = [master_cp.other_reference]
    all_references += duplicates.map(&:other_reference)
    all_references = all_references.compact.reject(&:blank?).uniq

    if all_references.size > 1
      # Multiple unique references exist, combine them
      master_cp.other_reference = all_references.join("\n---\n")
      metadata_changed = true
      Rails.logger.debug "Combined #{all_references.size} unique other_reference values"
    elsif all_references.size == 1 && master_cp.other_reference.blank?
      # Only one non-empty reference and master doesn't have it
      master_cp.other_reference = all_references.first
      metadata_changed = true
      Rails.logger.debug "Merged other_reference from duplicate"
    end

    master_cp.save! if metadata_changed
    metadata_changed
  end

  # Determine the most advanced screening status from a list of CitationsProjects
  # Prioritizes non-rejected statuses and workflow progression
  def select_master_by_status(citations_projects)
    return citations_projects.first if citations_projects.size == 1

    # Workflow progression order (higher number = more advanced)
    status_order = {
      CitationsProject::AS_UNSCREENED => 0,
      CitationsProject::AS_PARTIALLY_SCREENED => 1,
      CitationsProject::AS_IN_CONFLICT => 2,
      CitationsProject::FS_UNSCREENED => 3,
      CitationsProject::FS_PARTIALLY_SCREENED => 4,
      CitationsProject::FS_IN_CONFLICT => 5,
      CitationsProject::E_NEED_EXTRACTION => 6,
      CitationsProject::E_IN_PROGRESS => 7,
      CitationsProject::E_COMPLETE => 8,
      CitationsProject::C_NEED_CONSOLIDATION => 9,
      CitationsProject::C_IN_PROGRESS => 10,
      CitationsProject::C_COMPLETE => 11
    }

    # Separate rejected from non-rejected
    non_rejected = citations_projects.reject { |cp| CitationsProject::REJECTED.include?(cp.screening_status) }
    rejected = citations_projects.select { |cp| CitationsProject::REJECTED.include?(cp.screening_status) }

    Rails.logger.debug "DEBUG select_master_by_status: non_rejected ids=#{non_rejected.map(&:id)}, rejected ids=#{rejected.map(&:id)}"

    # Prefer non-rejected if available
    candidates = non_rejected.any? ? non_rejected : rejected
    Rails.logger.debug "DEBUG select_master_by_status: candidates ids=#{candidates.map(&:id)}"

    # Find the one with the most advanced status
    master = candidates.max_by do |cp|
      rank = status_order[cp.screening_status] || -1
      # If statuses are equal, use association count as tiebreaker
      assoc_count = association_count(cp)
      Rails.logger.debug "DEBUG select_master_by_status: CP #{cp.id} rank=#{rank}, assoc_count=#{assoc_count}"
      [rank, assoc_count]
    end

    Rails.logger.debug "Selected master CP #{master.id} with status '#{master.screening_status}' from #{citations_projects.size} candidates"
    master
  end

  # Report error to Sentry only in production
  def report_sentry(error)
    return unless Rails.env.production? && defined?(Sentry)

    Sentry.capture_exception(error)
  end
end
