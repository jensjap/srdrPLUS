class SdPicodsTypesController < ApplicationController
  def index
    @sd_picods_types = SdPicodsType.by_query(params[:q])
  end
end
