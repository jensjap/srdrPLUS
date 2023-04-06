class SdResultItemsController < ApplicationController
  def update
    sd_result_item = SdResultItem.find_by(id: params[:id])
    authorize(sd_result_item)
    sd_result_item.update!(sd_result_item_params)
    render json: sd_result_item.as_json, status: 200
  end

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_result_item = sd_meta_datum.sd_result_items.create(sd_result_item_params)
    render json: {
      id: sd_result_item.id,
      sd_key_questions: [],
      sd_narrative_results: [],
      sd_evidence_tables: [],
      sd_pairwise_meta_analytic_results: [],
      sd_network_meta_analysis_results: [],
      sd_meta_regression_analysis_results: []
    },
           status: 200
  end

  def destroy
    sd_result_item = SdResultItem.find_by(id: params[:id])
    authorize(sd_result_item)
    sd_result_item.destroy
    render json: sd_result_item.as_json, status: 200
  end

  private

  def sd_result_item_params
    params.permit(:sd_key_question_id)
  end
end
