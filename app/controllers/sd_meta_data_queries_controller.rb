class SdMetaDataQueriesController < ApplicationController
  before_action :set_sd_meta_data_query, only: [:destroy, :update]
  def create
    @sd_meta_data_query = SdMetaDataQuery.create( sd_meta_data_query_params )
  end

  def update
    respond_to do |format|
      if @sd_meta_data_query.update sd_meta_data_query_params
        format.json { render json: @sd_meta_data_query, status: :created }
      else
        format.json { render json: @sd_meta_data_query.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    respond_to do |format|
      if @sd_meta_data_query.destroy
        format.json { head :no_content }
      else
        format.json { render json: @sd_meta_data_query.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    def set_sd_meta_data_query
      @sd_meta_data_query = SdMetaDataQuery.find params[:id] 
    end
    
    # params are scary, use protection
    def sd_meta_data_query_params
      params.require(:sd_meta_data_query).permit(:sd_meta_datum_id, :projects_user_id, :query_text)
    end
end
