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

    scores_with_labels = MlPrediction.joins("LEFT JOIN citations_projects ON citations_projects.id = ml_predictions.citations_project_id")
                                     .joins("LEFT JOIN abstract_screening_results ON abstract_screening_results.citations_project_id = citations_projects.id")
                                     .where("ml_predictions.ml_model_id = ?", latest_ml_model.id)
                                     .where.not("abstract_screening_results.label" => nil)
                                     .select("abstract_screening_results.label, ml_predictions.score")

    label_score_map = scores_with_labels.each_with_object(Hash.new { |h, k| h[k] = [] }) do |prediction, hash|
      hash[prediction.label] << prediction.score
    end

    label_score_map
  end
end
