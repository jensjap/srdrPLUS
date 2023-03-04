class SdGreyLiteratureSearchesController < ApplicationController
  def update
    sd_grey_literature_search = SdGreyLiteratureSearch.find_by(id: params[:id])
    authorize(sd_grey_literature_search)
    sd_grey_literature_search.update(sd_grey_literature_search_params)
    render json: sd_grey_literature_search.as_json, status: 200
  end

  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    sd_grey_literature_search = sd_meta_datum.sd_grey_literature_searches.create(sd_grey_literature_search_params)
    render json: sd_grey_literature_search.as_json, status: 200
  end

  def destroy
    sd_grey_literature_search = SdGreyLiteratureSearch.find_by(id: params[:id])
    authorize(sd_grey_literature_search)
    sd_grey_literature_search.destroy
    render json: sd_grey_literature_search.as_json, status: 200
  end

  private

  def sd_grey_literature_search_params
    params.permit(:name)
  end
end
