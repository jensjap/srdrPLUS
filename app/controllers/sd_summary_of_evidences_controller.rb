class SdSummaryOfEvidencesController < ApplicationController
  def update
    sd_summary_of_evidence = SdSummaryOfEvidence.find_by(id: params[:id])
    authorize(sd_summary_of_evidence)
    sd_summary_of_evidence.update!(sd_summary_of_evidence_params)
    render json: sd_summary_of_evidence.as_json, status: 200
  end

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_summary_of_evidence = sd_meta_datum.sd_summary_of_evidences.create(sd_summary_of_evidence_params)
    render json: { id: sd_summary_of_evidence.id, name: sd_summary_of_evidence.name, sd_meta_data_figures: [] },
           status: 200
  end

  def destroy
    sd_summary_of_evidence = SdSummaryOfEvidence.find_by(id: params[:id])
    authorize(sd_summary_of_evidence)
    sd_summary_of_evidence.destroy
    render json: sd_summary_of_evidence.as_json, status: 200
  end

  private

  def sd_summary_of_evidence_params
    params.permit(:name, :soe_type)
  end
end
