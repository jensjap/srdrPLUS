class SdSearchStrategiesController < ApplicationController
  def update
    sd_search_strategy = SdSearchStrategy.find_by(id: params[:id])
    authorize(sd_search_strategy)
    sd_search_strategy.update(sd_search_strategy_params)
    render json: sd_search_strategy.as_json, status: 200
  end

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_search_strategy = sd_meta_datum.sd_search_strategies.create(sd_search_strategy_params)
    render json: sd_search_strategy.as_json, status: 200
  end

  def destroy
    sd_search_strategy = SdSearchStrategy.find_by(id: params[:id])
    authorize(sd_search_strategy)
    sd_search_strategy.destroy
    render json: sd_search_strategy.as_json, status: 200
  end

  private

  def sd_search_strategy_params
    params.permit(
      :sd_search_database_id,
      :date_of_search,
      :search_limits,
      :search_terms
    )
  end
end
