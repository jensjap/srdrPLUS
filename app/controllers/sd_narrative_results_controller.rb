class SdNarrativeResultsController < ApplicationController
  def update
    sd_narrative_result = SdNarrativeResult.find_by(id: params[:id])
    authorize(sd_narrative_result)
    sd_narrative_result.update(sd_narrative_result_params)
    render json: sd_narrative_result.as_json, status: 200
  end

  def create
    sd_result_item = SdResultItem.find(params[:sd_result_item_id])
    authorize(sd_result_item)
    sd_narrative_result = sd_result_item.sd_narrative_results.create(sd_narrative_result_params)
    render json: sd_narrative_result.as_json, status: 200
  end

  def destroy
    sd_narrative_result = SdNarrativeResult.find_by(id: params[:id])
    authorize(sd_narrative_result)
    sd_narrative_result.destroy
    render json: sd_narrative_result.as_json, status: 200
  end

  private

  def sd_narrative_result_params
    params.permit(
      :narrative_results,
      :narrative_results_by_population,
      :narrative_results_by_intervention
    )
  end
end
