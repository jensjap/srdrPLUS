class FundingSourcesSdMetaDataController < ApplicationController
  def create
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    funding_source = FundingSource.find_or_create_by(name: params[:funding_source_name])
    sd_meta_datum.funding_sources << funding_source unless sd_meta_datum.funding_sources.include?(funding_source)
    render json: {}, status: 200
  end

  def destroy
    sd_meta_datum = SdMetaDatum.find(params[:sd_meta_datum_id])
    authorize(sd_meta_datum)
    funding_source = FundingSource.find_by(name: params[:funding_source_name])
    sd_meta_datum.funding_sources.delete(funding_source) if funding_source
    render json: {}, status: 200
  end
end
