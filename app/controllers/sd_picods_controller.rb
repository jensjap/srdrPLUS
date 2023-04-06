class SdPicodsController < ApplicationController
  def update
    sd_picod = SdPicod.find_by(id: params[:id])
    authorize(sd_picod)
    sd_picod.update(sd_picod_params)
    render json: sd_picod.as_json, status: 200
  end

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_picod = sd_meta_datum.sd_picods.create(sd_picod_params)
    render json: sd_picod.as_json, status: 200
  end

  def destroy
    sd_picod = SdPicod.find_by(id: params[:id])
    authorize(sd_picod)
    sd_picod.destroy
    render json: sd_picod.as_json, status: 200
  end

  private

  def sd_picod_params
    params.permit(:name,
                  :population,
                  :interventions,
                  :comparators,
                  :outcomes,
                  :study_designs,
                  :settings,
                  :data_analysis_level_id,
                  :timing,
                  :other_elements)
  end
end
