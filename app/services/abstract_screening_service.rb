class AbstractScreeningService < BaseScreeningService
  def self.asr_in_asic_count(abstract_screening)
    CitationsProject
      .left_joins(:abstract_screening_results)
      .where(
        project: abstract_screening.project,
        screening_status: CitationsProject::AS_IN_CONFLICT,
        abstract_screening_results: { abstract_screening: }
      )
      .uniq
      .count
  end

  def self.find_asr_to_be_resolved(abstract_screening, user, create_record = true)
    unfinished_privileged_asrs =
      abstract_screening
      .abstract_screening_results
      .includes(:citations_project)
      .where(
        privileged: true,
        label: nil,
        citations_project: { screening_status: CitationsProject::AS_IN_CONFLICT }
      )
      .order(id: :ASC)
    skipped_privileged_asrs =
      abstract_screening
      .abstract_screening_results
      .includes(:citations_project)
      .where(
        privileged: true,
        label: 0,
        citations_project: { screening_status: CitationsProject::AS_IN_CONFLICT }
      )
      .order(updated_at: :ASC)
    unfinished_privileged_asr = unfinished_privileged_asrs.first
    return unfinished_privileged_asr if unfinished_privileged_asr

    citations_projects =
      CitationsProject
      .left_joins(:abstract_screening_results)
      .where(
        project: abstract_screening.project,
        screening_status: CitationsProject::AS_IN_CONFLICT,
        abstract_screening_results: { abstract_screening: }
      )
      .order('abstract_screening_results.id ASC')
    citations_projects = citations_projects.filter do |cp|
      cp.abstract_screening_results.none? do |asr|
        asr.privileged && asr.label&.zero?
      end
    end
    if abstract_screening.project.exclude_personal_conflicts
      citations_projects = citations_projects.filter do |cp|
        cp.abstract_screening_results.none? do |asr|
          asr.user == user
        end
      end
    end
    citations_projects += skipped_privileged_asrs.map(&:citations_project)
    citations_project = citations_projects.first

    return nil unless citations_project
    return true unless create_record

    if (asr = AbstractScreeningResult.find_by(abstract_screening:, citations_project:, privileged: true))
      asr
    else
      AbstractScreeningResult.find_or_create_by!(user:, abstract_screening:, citations_project:, privileged: true)
    end
  end

  def self.get_next_singles_citation_id(abstract_screening, x = 0)
    project_screened_citation_ids = project_screened_citation_ids(abstract_screening.project)
    non_asu_citation_ids =
      CitationsProject
      .where(project: abstract_screening.project)
      .where.not(
        screening_status: CitationsProject::AS_UNSCREENED
      )
      .map(&:citation_id)
    ineligible_citation_ids = (project_screened_citation_ids + non_asu_citation_ids).uniq
    preferred_citation = abstract_screening
                         .project
                         .citations
                         .joins('INNER JOIN citations_projects AS cp1 ON cp1.citation_id = citations.id')
                         .joins('INNER JOIN ml_predictions AS mp1 ON mp1.citations_project_id = cp1.id')
                         .joins('LEFT JOIN ml_predictions AS mp2 ON
                                   (
                                     mp1.citations_project_id = mp2.citations_project_id
                                     AND
                                     mp1.created_at < mp2.created_at
                                   )')
                         .where('mp2.id IS NULL')
                         .where.not(id: ineligible_citation_ids)
                         .where('mp1.score BETWEEN ? AND ?', 0.5 - x, 0.5 + x)
                         .sample

    return preferred_citation.id if preferred_citation.present?

    highest_score_citation = abstract_screening
                             .project
                             .citations
                             .joins('INNER JOIN citations_projects AS cp2 ON cp2.citation_id = citations.id')
                             .joins('INNER JOIN ml_predictions AS mp3 ON mp3.citations_project_id = cp2.id')
                             .joins('LEFT JOIN ml_predictions AS mp4 ON
                                        (
                                          mp3.citations_project_id = mp4.citations_project_id
                                          AND
                                          mp3.created_at < mp4.created_at
                                        )')
                             .where('mp4.id IS NULL')
                             .where.not(id: ineligible_citation_ids)
                             .order('mp3.score DESC')
                             .first

    return highest_score_citation.id if highest_score_citation.present?

    random_citation = abstract_screening
                      .project
                      .citations
                      .joins('INNER JOIN citations_projects AS cp2 ON cp2.citation_id = citations.id')
                      .where.not(id: ineligible_citation_ids)
                      .sample

    random_citation&.id
  end

  def self.count_recent_consecutive_rejects(project)
    last_reject_streak = 0
    previous_result_rejected = true
    original_labels = {}

    grouped_results = project.abstract_screenings
                             .includes(:abstract_screening_results)
                             .flat_map do |screening|
                               screening.abstract_screening_results.group_by do |result|
                                 [result.citations_project_id, screening]
                               end
                             end
    filtered_grouped_results = grouped_results.reject { |group| group.empty? }

    adjusted_results = filtered_grouped_results.flat_map do |group|
      group.map do |(_citation_project_id, screening), results|
        next if results.nil? || results.empty?

        results.each do |result|
          qualification = ScreeningQualification.find_by(citations_project_id: result.citations_project_id)
          if qualification.present?
            original_labels[result] = result.label unless original_labels.key?(result)
            result.label = qualification.qualification_type == 'as-accepted' ? 1 : -1
          end
        end

        if results.any?(&:privileged)
          privileged_label = results.find(&:privileged).label
          results.each do |result|
            original_labels[result] = result.label unless original_labels.key?(result)
            result.label = privileged_label
          end
        end

        [results, screening]
      end
    end.compact

    adjusted_and_filtered_results = adjusted_results.reject do |results, _screening|
      results.all? { |result| result.label.nil? }
    end

    sorted_and_adjusted_results = adjusted_and_filtered_results.sort_by { |results, _| results.map(&:created_at).min }.reverse

    sorted_and_adjusted_results.each do |results, screening|
      screening_type = if screening.single_screening?
                         :single_screening
                       elsif screening.double_screening?
                         :double_screening
                       elsif screening.all_screenings?
                         :all_screenings
                       end

      is_rejected = case screening_type
                    when :single_screening
                      results.any? { |result| result.label == -1 }
                    when :double_screening, :all_screenings
                      non_nil_labels = results.map(&:label).compact
                      non_nil_labels.present? && non_nil_labels.all? { |label| label == -1 }
                    else
                      false
                    end

      break unless is_rejected

      if previous_result_rejected
        last_reject_streak += 1
      else
        last_reject_streak = 1
        previous_result_rejected = true
      end
    end

    original_labels.each do |result, original_label|
      result.label = original_label
    end

    last_reject_streak
  end
end
