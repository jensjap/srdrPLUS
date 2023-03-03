class SdMetaDataFiguresController < ApplicationController
  def create
    sd_figurable_type = params[:sd_figurable_type]
    return render json: {}, status: 400 unless SdMetaDataFigure::SD_FIGURABLE_TYPES.include?(sd_figurable_type)

    sd_figurable = sd_figurable_type.constantize.find(params[:sd_figurable_id])
    authorize(sd_figurable)
    sd_meta_data_figure = SdMetaDataFigure.create(alt_text: params[:alt_text], sd_figurable:)
    render json: { id: sd_meta_data_figure.id, alt_text: sd_meta_data_figure.alt_text }, status: 200
  end

  def update
    sd_meta_data_figure = SdMetaDataFigure.find_by(id: params[:id])
    authorize(sd_meta_data_figure)
    sd_meta_data_figure.update(alt_text: params[:alt_text])
    render json: { id: sd_meta_data_figure.id, alt_text: sd_meta_data_figure.alt_text }, status: 200
  end

  def destroy
    sd_meta_data_figure = SdMetaDataFigure.find_by(id: params[:id])
    authorize(sd_meta_data_figure)
    sd_meta_data_figure.destroy
    render json: { id: sd_meta_data_figure.id }, status: 200
  end
end
