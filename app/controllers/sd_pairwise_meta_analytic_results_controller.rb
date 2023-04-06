class SdPairwiseMetaAnalyticResultsController < ApplicationController
  def update
    sd_pairwise_meta_analytic_result = SdPairwiseMetaAnalyticResult.find_by(id: params[:id])
    authorize(sd_pairwise_meta_analytic_result)
    sd_pairwise_meta_analytic_result.update(sd_pairwise_meta_analytic_result_params)
    render json: sd_pairwise_meta_analytic_result.as_json, status: 200
  end

  def create
    sd_result_item = SdResultItem.find(params[:sd_result_item_id])
    authorize(sd_result_item)
    sd_pairwise_meta_analytic_result = sd_result_item.sd_pairwise_meta_analytic_results.create(sd_pairwise_meta_analytic_result_params)
    render json: {
      id: sd_pairwise_meta_analytic_result.id,
      sd_meta_data_figures: []
    }, status: 200
  end

  def destroy
    sd_pairwise_meta_analytic_result = SdPairwiseMetaAnalyticResult.find_by(id: params[:id])
    authorize(sd_pairwise_meta_analytic_result)
    sd_pairwise_meta_analytic_result.destroy
    render json: sd_pairwise_meta_analytic_result.as_json, status: 200
  end

  private

  def sd_pairwise_meta_analytic_result_params
    params.permit(:name)
  end
end
