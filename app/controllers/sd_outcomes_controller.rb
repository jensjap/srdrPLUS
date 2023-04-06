class SdOutcomesController < ApplicationController
  def index
    outcomeable =
      if (sd_narrative_result_id = params[:sd_narrative_result_id])
        SdNarrativeResult.find(sd_narrative_result_id)
      elsif (sd_evidence_table_id = params[:sd_evidence_table_id])
        SdEvidenceTable.find(sd_evidence_table_id)
      elsif (sd_pairwise_meta_analytic_result_id = params[:sd_pairwise_meta_analytic_result_id])
        SdPairwiseMetaAnalyticResult.find(sd_pairwise_meta_analytic_result_id)
      elsif (sd_network_meta_analysis_result_id = params[:sd_network_meta_analysis_result_id])
        SdNetworkMetaAnalysisResult.find(sd_network_meta_analysis_result_id)
      elsif (sd_meta_regression_analysis_result_id = params[:sd_meta_regression_analysis_result_id])
        SdMetaRegressionAnalysisResult.find(sd_meta_regression_analysis_result_id)
      end

    return render json: {}, status: 400 unless outcomeable

    sd_meta_datum = outcomeable.sd_result_item.sd_meta_datum
    authorize(sd_meta_datum)
    sd_outcomes = []
    SdMetaDatum.includes(sd_result_items: [sd_narrative_results: :sd_outcomes, sd_evidence_tables: :sd_outcomes, sd_pairwise_meta_analytic_results: :sd_outcomes, sd_network_meta_analysis_results: :sd_outcomes, sd_meta_regression_analysis_results: :sd_outcomes]).find_by(id: sd_meta_datum.id).sd_result_items.each do |sd_result_item|
      sd_result_item.sd_narrative_results.each do |sd_narrative_result|
        sd_narrative_result.sd_outcomes.each do |sd_outcome|
          sd_outcomes << sd_outcome
        end
      end
      sd_result_item.sd_evidence_tables.each do |sd_evidence_table|
        sd_evidence_table.sd_outcomes.each do |sd_outcome|
          sd_outcomes << sd_outcome
        end
      end
      sd_result_item.sd_pairwise_meta_analytic_results.each do |sd_pairwise_meta_analytic_result|
        sd_pairwise_meta_analytic_result.sd_outcomes.each do |sd_outcome|
          sd_outcomes << sd_outcome
        end
      end
      sd_result_item.sd_network_meta_analysis_results.each do |sd_network_meta_analysis_result|
        sd_network_meta_analysis_result.sd_outcomes.each do |sd_outcome|
          sd_outcomes << sd_outcome
        end
      end
      sd_result_item.sd_meta_regression_analysis_results.each do |sd_meta_regression_analysis_result|
        sd_meta_regression_analysis_result.sd_outcomes.each do |sd_outcome|
          sd_outcomes << sd_outcome
        end
      end
    end
    @sd_outcomes = sd_outcomes.uniq(&:name)
  end

  def create
    sd_outcomeable_type = params[:sd_outcomeable_type]
    return render json: {}, status: 400 unless SdOutcome::SD_OUTCOMEABLE_TYPES.include?(sd_outcomeable_type)

    sd_outcomeable = sd_outcomeable_type.constantize.find(params[:sd_outcomeable_id])
    authorize(sd_outcomeable)
    sd_outcome = sd_outcomeable.sd_outcomes.create(sd_outcome_params)
    render json: { id: sd_outcome.id, name: sd_outcome.name }, status: 200
  end

  def destroy
    sd_outcome = SdOutcome.find_by(sd_outcomeable_type: params[:sd_outcomeable_type],
                                   sd_outcomeable_id: params[:sd_outcomeable_id], name: params[:name])
    authorize(sd_outcome)
    sd_outcome.destroy
    render json: sd_outcome.as_json, status: 200
  end

  private

  def sd_outcome_params
    params.permit(:name)
  end
end
