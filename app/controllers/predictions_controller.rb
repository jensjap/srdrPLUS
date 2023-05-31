class PredictionsController < ApplicationController
  def get_unlabeled_with_intervals
    scores_intervals = {
      '0.0-0.1' => 10,
      '0.1-0.2' => 20,
      '0.2-0.3' => 30,
      '0.3-0.4' => 40,
      '0.4-0.5' => 50,
      '0.5-0.6' => 60,
      '0.6-0.7' => 70,
      '0.7-0.8' => 80,
      '0.8-0.9' => 90,
      '0.9-1.0' => 100
    }
    ### If production, uncomment ###
    #scores_intervals = MachineLearningDataSupplyingService.get_unlabeled_predictions_with_intervals(params[:id])
    render json: scores_intervals
  end
end
