class AbstractScreeningResultsReasonsController < ApplicationController
  def create
    reason = Reason.find_or_create_by(id: params[:reason_id])
    abstract_screening_results_reason =
      AbstractScreeningResultsReason.find_or_create_by(
        abstract_screening_result_id: params[:abstract_screening_result_id], reason:
      )
    render json: abstract_screening_results_reason, status: 200
  end

  def destroy
    abstract_screening_results_reason = AbstractScreeningResultsReason.find(params[:id])
    abstract_screening_results_reason.destroy
    render json: abstract_screening_results_reason, status: 200
  end
end
