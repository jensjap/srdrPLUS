class MachineLearningStatisticService
  def self.get_unscreened_prediction_scores(project_id)

    latest_ml_model = MlModel.joins(:projects)
                             .where("projects.id = ?", project_id)
                             .order(created_at: :desc)
                             .limit(1)
                             .first

    return [] unless latest_ml_model

    unscreened_scores = MlPrediction.joins("LEFT JOIN citations_projects ON citations_projects.id = ml_predictions.citations_project_id")
                                    .joins("LEFT JOIN abstract_screening_results ON abstract_screening_results.citations_project_id = citations_projects.id")
                                    .where("ml_predictions.ml_model_id = ?", latest_ml_model.id)
                                    .where("abstract_screening_results.id IS NULL")
                                    .pluck(:score)

    unscreened_scores
  end

  def self.latest_model_time(project_id)
    latest_ml_model = MlModel.joins(:projects)
                             .where("projects.id = ?", project_id)
                             .order(created_at: :desc)
                             .limit(1)
                             .first
    latest_ml_model&.created_at
  end

  def self.get_labels_with_scores(project_id)
    latest_ml_model = MlModel.joins(:projects)
                             .where("projects.id = ?", project_id)
                             .order(created_at: :desc)
                             .limit(1)
                             .first
    return {} unless latest_ml_model

    model_performances = ModelPerformance.where(ml_model_id: latest_ml_model.id)

    label_score_map = model_performances.each_with_object(Hash.new { |h, k| h[k] = [] }) do |performance, hash|
      hash[performance.label] << performance.score
    end

    label_score_map
  end

  def self.get_estimated_coverage_to_total_size(project_id)
    total_size = Project.find(project_id).citations.count
    label_array = get_rejection_array(project_id)

    label_size = label_array.size
    label_statistic = []
    threshold_ratio = label_size.to_f / total_size

    fixed_number = 100
    back_segment_size = [fixed_number, (total_size * 0.1).ceil].max

    (1..10).each do |i|
      ratio = i / 10.0
      front_segment_size = (total_size * ratio).ceil
      front_segment = label_array[0...front_segment_size]

      break if front_segment_size > front_segment.size

      if front_segment_size < back_segment_size
        back_segment = front_segment
      else
        back_segment = front_segment[-back_segment_size..-1]
      end

      front_count = front_segment.count(1)
      back_count = back_segment.count(1)
      back_ratio = back_segment.empty? ? 0 : back_count.to_f / back_segment.size

      estimated_positive = front_count + (total_size * (1 - ratio) * back_ratio).to_i
      estimated_coverage = estimated_positive.zero? ? 0 : front_count.to_f / estimated_positive

      if ratio > threshold_ratio
        next
      end

      label_statistic << {
        ratio: ratio,
        front_size: front_segment_size,
        front_count: front_count,
        back_ratio: back_ratio,
        estimated_positive: estimated_positive,
        estimated_coverage: estimated_coverage
      }
    end

    threshold_front_segment_size = (total_size * threshold_ratio).ceil
    threshold_front_segment = label_array[0...threshold_front_segment_size]

    if threshold_front_segment_size < back_segment_size
      threshold_back_segment = threshold_front_segment
    else
      threshold_back_segment = threshold_front_segment[-back_segment_size..-1]
    end

    threshold_front_count = threshold_front_segment.count(1)
    threshold_back_count = threshold_back_segment.count(1)
    threshold_back_ratio = threshold_back_segment.empty? ? 0 : threshold_back_count.to_f / threshold_back_segment.size

    threshold_estimated_positive = threshold_front_count + (total_size * (1 - threshold_ratio) * threshold_back_ratio).to_i
    threshold_estimated_coverage = threshold_estimated_positive.zero? ? 0 : threshold_front_count.to_f / threshold_estimated_positive

    label_statistic << {
      ratio: threshold_ratio,
      front_size: threshold_front_segment_size,
      front_count: threshold_front_count,
      back_ratio: threshold_back_ratio,
      estimated_positive: threshold_estimated_positive,
      estimated_coverage: threshold_estimated_coverage
    }

    label_statistic
  end

  def self.count_recent_consecutive_rejects(project_id)
    grouped_results = group_screening_results(project_id)
    adjusted_results = adjust_results(grouped_results)
    sorted_and_adjusted_results = sort_results(adjusted_results)

    calculate_reject_streak(sorted_and_adjusted_results)
  end

  private

  def self.get_rejection_array(project_id)
    grouped_results = group_screening_results(project_id)
    adjusted_results = adjust_results(grouped_results)
    sorted_and_adjusted_results = sort_results(adjusted_results)

    generate_rejection_array(sorted_and_adjusted_results.reverse)
  end

  def self.generate_rejection_array(sorted_and_adjusted_results)
    rejection_array = []

    sorted_and_adjusted_results.each do |results, screening|
      screening_type = determine_screening_type(screening)
      is_rejected = determine_rejection(screening_type, results)

      rejection_array << (is_rejected ? 0 : 1)
    end

    rejection_array
  end

  def self.group_screening_results(project_id)
    project = Project.includes(
      abstract_screenings: {
        abstract_screening_results: { citations_project: :screening_qualifications }
      }
    ).find(project_id)
    project.abstract_screenings.flat_map do |screening|
      screening.abstract_screening_results.group_by do |result|
        [result.citations_project_id, screening]
      end
    end.reject { |group| group.empty? }
  end

  def self.adjust_results(grouped_results)
    grouped_results.flat_map do |group|
      group.map do |(_citation_project_id, screening), results|
        next if results.nil? || results.empty?

        qualifications_map = get_qualifications_map(results.first.citations_project.screening_qualifications)
        update_labels(results, qualifications_map)

        if results.any?(&:privileged)
          privileged_label = results.find(&:privileged).label
          results.each do |result|
            result.label = privileged_label
          end
        end

        [results, screening]
      end
    end.compact.reject { |results, _screening| results.all? { |result| result.label.nil? } }
  end

  def self.get_qualifications_map(screening_qualifications)
    filtered_qualifications = screening_qualifications.select do |qualification|
      qualification.qualification_type == 'as-accepted' || qualification.qualification_type == 'as-rejected'
    end

    filtered_qualifications.index_by(&:citations_project_id)
  end

  def self.update_labels(results, qualifications_map)
    results.each do |result|
      qualification = qualifications_map[result.citations_project_id]
      if qualification.present?
        result.label = qualification.qualification_type == 'as-accepted' ? 1 : -1
      end
    end
  end

  def self.sort_results(adjusted_results)
    adjusted_results.sort_by { |results, _| results.map(&:created_at).min }.reverse
  end

  def self.calculate_reject_streak(sorted_and_adjusted_results)
    last_reject_streak = 0
    previous_result_rejected = true

    sorted_and_adjusted_results.each do |results, screening|
      screening_type = determine_screening_type(screening)
      is_rejected = determine_rejection(screening_type, results)

      break unless is_rejected

      if previous_result_rejected
        last_reject_streak += 1
      else
        last_reject_streak = 1
        previous_result_rejected = true
      end
    end

    last_reject_streak
  end

  def self.determine_screening_type(screening)
    if screening.single_screening?
      :single_screening
    elsif screening.double_screening?
      :double_screening
    elsif screening.all_screenings?
      :all_screenings
    end
  end

  def self.determine_rejection(screening_type, results)
    case screening_type
    when :single_screening
      results.any? { |result| result.label == -1 }
    when :double_screening, :all_screenings
      non_nil_labels = results.map(&:label).compact
      non_nil_labels.present? && non_nil_labels.all? { |label| label == -1 }
    else
      false
    end
  end
end
