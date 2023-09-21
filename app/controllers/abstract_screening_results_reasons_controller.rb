class AbstractScreeningResultsReasonsController < ApplicationController
  def create
    abstract_screening_result = AbstractScreeningResult.find(params[:abstract_screening_result_id])
    authorize(abstract_screening_result)

    reason = Reason.find_or_create_by(id: params[:reason_id])
    abstract_screening_results_reason =
      AbstractScreeningResultsReason.find_or_create_by(
        abstract_screening_result:, reason:
      )
    render json: abstract_screening_results_reason, status: 200
  end

  def destroy
    abstract_screening_results_reason = AbstractScreeningResultsReason.find(params[:id])
    authorize(abstract_screening_results_reason)
    abstract_screening_results_reason.destroy
    render json: abstract_screening_results_reason, status: 200
  end
end
