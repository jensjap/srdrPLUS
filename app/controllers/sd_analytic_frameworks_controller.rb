class SdAnalyticFrameworksController < ApplicationController
  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_analytic_framework = SdAnalyticFramework.create(sd_meta_datum:)
    render json: { id: sd_analytic_framework.id, name: sd_analytic_framework.name, sd_meta_data_figures: [] }, status: 200
  end

  def update
    sd_analytic_framework = SdAnalyticFramework.find_by(id: params[:id])
    authorize(sd_analytic_framework)
    sd_analytic_framework.update(name: params[:name])
    render json: sd_analytic_framework.as_json, status: 200
  end

  def destroy
    sd_analytic_framework = SdAnalyticFramework.find_by(id: params[:id])
    authorize(sd_analytic_framework)
    sd_analytic_framework.destroy
    render json: { id: sd_analytic_framework.id }, status: 200
  end
end
