class FulltextScreeningResultsReasonsController < ApplicationController
  def create
    fulltext_screening_result = FulltextScreeningResult.find(params[:fulltext_screening_result_id])
    authorize(fulltext_screening_result, :update?)

    reason = Reason.find_or_create_by(id: params[:reason_id])
    fulltext_screening_results_reason =
      FulltextScreeningResultsReason.find_or_create_by(
        fulltext_screening_result:, reason:
      )
    render json: fulltext_screening_results_reason, status: 200
  end

  def destroy
    fulltext_screening_results_reason = FulltextScreeningResultsReason.find(params[:id])
    authorize(fulltext_screening_results_reason)
    fulltext_screening_results_reason.destroy
    render json: fulltext_screening_results_reason, status: 200
  end
end
