class SdOtherItemsController < ApplicationController
  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_other_item = SdOtherItem.create(name: params[:name], sd_meta_datum:)
    render json: { id: sd_other_item.id, name: sd_other_item.name }, status: 200
  end

  def update
    sd_other_item = SdOtherItem.find_by(id: params[:id])
    authorize(sd_other_item)
    sd_other_item.update(name: params[:name])
    render json: { id: sd_other_item.id, name: sd_other_item.name }, status: 200
  end

  def destroy
    sd_other_item = SdOtherItem.find_by(id: params[:id])
    authorize(sd_other_item)
    sd_other_item.destroy
    render json: { id: sd_other_item.id }, status: 200
  end
end
