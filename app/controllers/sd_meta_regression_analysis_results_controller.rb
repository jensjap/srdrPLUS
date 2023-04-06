class SdMetaRegressionAnalysisResultsController < ApplicationController
  def update
    sd_meta_regression_analysis_result = SdMetaRegressionAnalysisResult.find_by(id: params[:id])
    authorize(sd_meta_regression_analysis_result)
    sd_meta_regression_analysis_result.update(sd_meta_regression_analysis_result_params)
    render json: sd_meta_regression_analysis_result.as_json, status: 200
  end

  def create
    sd_result_item = SdResultItem.find(params[:sd_result_item_id])
    authorize(sd_result_item)
    sd_meta_regression_analysis_result = sd_result_item.sd_meta_regression_analysis_results.create(sd_meta_regression_analysis_result_params)
    render json: {
      id: sd_meta_regression_analysis_result.id,
      sd_meta_data_figures: []
    }, status: 200
  end

  def destroy
    sd_meta_regression_analysis_result = SdMetaRegressionAnalysisResult.find_by(id: params[:id])
    authorize(sd_meta_regression_analysis_result)
    sd_meta_regression_analysis_result.destroy
    render json: sd_meta_regression_analysis_result.as_json, status: 200
  end

  private

  def sd_meta_regression_analysis_result_params
    params.permit(:name)
  end
end
