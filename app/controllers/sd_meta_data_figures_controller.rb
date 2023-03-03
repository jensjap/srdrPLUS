class SdMetaDataFiguresController < ApplicationController
  def create
    sd_figurable_type = params[:sd_figurable_type]
    return render json: {}, status: 400 unless SdMetaDataFigure::SD_FIGURABLE_TYPES.include?(sd_figurable_type)

    sd_figurable = sd_figurable_type.constantize.find(params[:sd_figurable_id])
    authorize(sd_figurable)
    sd_meta_data_figure = sd_figurable.sd_meta_data_figures.create(sd_meta_data_figure_params)
    render json: { id: sd_meta_data_figure.id, alt_text: sd_meta_data_figure.alt_text }, status: 200
  end

  def update
    sd_meta_data_figure = SdMetaDataFigure.find_by(id: params[:id])
    authorize(sd_meta_data_figure)
    sd_meta_data_figure.update(sd_meta_data_figure_params)
    render json: {
      id: sd_meta_data_figure.id,
      alt_text: sd_meta_data_figure.alt_text,
      pictures: sd_meta_data_figure.pictures.map { |picture| { id: picture.id, url: rails_blob_url(picture) } }
    }, status: 200
  end

  def destroy
    sd_meta_data_figure = SdMetaDataFigure.find_by(id: params[:id])
    authorize(sd_meta_data_figure)
    sd_meta_data_figure.destroy
    render json: { id: sd_meta_data_figure.id }, status: 200
  end

  private

  def sd_meta_data_figure_params
    params.permit(:alt_text, pictures: [])
  end
end
