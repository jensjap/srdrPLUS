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
end
