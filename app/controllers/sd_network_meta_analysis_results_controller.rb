class SdNetworkMetaAnalysisResultsController < ApplicationController
  def update
    sd_network_meta_analysis_result = SdNetworkMetaAnalysisResult.find_by(id: params[:id])
    authorize(sd_network_meta_analysis_result)
    sd_network_meta_analysis_result.update(sd_network_meta_analysis_result_params)
    render json: sd_network_meta_analysis_result.as_json, status: 200
  end

  def create
    sd_result_item = SdResultItem.find(params[:sd_result_item_id])
    authorize(sd_result_item)
    sd_network_meta_analysis_result = sd_result_item.sd_network_meta_analysis_results.create(sd_network_meta_analysis_result_params)
    render json: sd_network_meta_analysis_result.as_json, status: 200
  end

  def destroy
    sd_network_meta_analysis_result = SdNetworkMetaAnalysisResult.find_by(id: params[:id])
    authorize(sd_network_meta_analysis_result)
    sd_network_meta_analysis_result.destroy
    render json: sd_network_meta_analysis_result.as_json, status: 200
  end

  private

  def sd_network_meta_analysis_result_params
    params.permit(:name)
  end
end
