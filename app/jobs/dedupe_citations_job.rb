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

      # Find master (the one with most associations)
      master_cp = lsof_cp.max_by { |cp| association_count(cp) }
      duplicates_to_merge = lsof_cp - [master_cp]

      Rails.logger.debug "Master CP: #{master_cp.id}, merging #{duplicates_to_merge.size} duplicates"

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

    # Use a more efficient approach to find duplicates
    duplicate_citation_groups = project.citations
                                       .select(:id, :citation_type_id, :name, :pmid, :abstract)
                                       .group_by { |c| [c.citation_type_id, c.name, c.pmid, c.abstract] }
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

        if master_cp && cp_to_remove
          transfer_all_associations(master_cp, cp_to_remove)
        elsif cp_to_remove.nil?
          Rails.logger.warn "CitationsProject not found for citation #{duplicate_citation.id} in project #{project.id}"
        elsif master_cp.nil?
          Rails.logger.warn "Master CitationsProject not found for citation #{master_citation.id} in project #{project.id}"
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
    records = cp_to_remove.public_send(assoc_name)
    return if records.empty?

    ids = records.map(&:id)
    return if ids.empty?

    begin
      updated_count = model_class.where(id: ids).update_all(citations_project_id: master_cp.id)
      Rails.logger.debug "Transferred #{updated_count} #{assoc_name} from CP #{cp_to_remove.id} to #{master_cp.id}"
    rescue StandardError => e
      Rails.logger.error "Failed to bulk transfer #{assoc_name}: #{e.message}"
      report_sentry(e)
      # Fallback to individual updates
      records.each do |record|
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

    # Use loaded associations if available, otherwise query counts
    extraction_count = cp.association(:extractions).loaded? ? cp.extractions.size : cp.extractions.count
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

    counts = {
      extractions: cp.association(:extractions).loaded? ? cp.extractions.size : cp.extractions.count,
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

  # Report error to Sentry only in production
  def report_sentry(error)
    return unless Rails.env.production? && defined?(Sentry)

    Sentry.capture_exception(error)
  end
end
