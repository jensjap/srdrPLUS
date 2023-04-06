class SdEvidenceTablesController < ApplicationController
  def update
    sd_evidence_table = SdEvidenceTable.find_by(id: params[:id])
    authorize(sd_evidence_table)
    sd_evidence_table.update(sd_evidence_table_params)
    render json: sd_evidence_table.as_json, status: 200
  end

  def create
    sd_result_item = SdResultItem.find(params[:sd_result_item_id])
    authorize(sd_result_item)
    sd_evidence_table = sd_result_item.sd_evidence_tables.create(sd_evidence_table_params)
    render json: {
      id: sd_evidence_table.id,
      sd_meta_data_figures: []
    }, status: 200
  end

  def destroy
    sd_evidence_table = SdEvidenceTable.find_by(id: params[:id])
    authorize(sd_evidence_table)
    sd_evidence_table.destroy
    render json: sd_evidence_table.as_json, status: 200
  end

  private

  def sd_evidence_table_params
    params.permit(:name)
  end
end
