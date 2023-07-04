class PredictionsController < ApplicationController
  def get_unlabeled_with_intervals
    stubbed_data = {
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
    empty_data = {
      '0.0-0.1' => 0,
      '0.1-0.2' => 0,
      '0.2-0.3' => 0,
      '0.3-0.4' => 0,
      '0.4-0.5' => 0,
      '0.5-0.6' => 0,
      '0.6-0.7' => 0,
      '0.7-0.8' => 0,
      '0.8-0.9' => 0,
      '0.9-1.0' => 0
    }
    scores_intervals = if MachineLearningDataSupplyingService.stub_ml_data?
                         stubbed_data
                       else
                         real_data = MachineLearningDataSupplyingService
                                     .get_unlabeled_predictions_with_intervals(params[:id])
                         real_data.blank? ? empty_data : real_data
                       end

    render json: scores_intervals
  end
end
