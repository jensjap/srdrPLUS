class SdMetaDataQueriesController < ApplicationController
  def create
    @sd_meta_data_query = SdMetaDataQuery.create( sd_meta_data_query_params )
  end

  def destroy
  end

  private
    # params are scary, use protection
    def sd_meta_data_query_params
      #params.require(:sd_meta_data_query).permit(:sd_meta_datum_id, :projects_user_id, query_text: [{ query_params: {  columns: [:name, :type, { export_items: [:export_id, :type, :extraction_forms_projects_section_id] }], kqp_ids: [] } }, { filter_params: { kqp_ids: [], type1s: {} } }]) 
      params.require(:sd_meta_data_query).permit(:sd_meta_datum_id, :projects_user_id, :query_text)
    end

    def set_sd_meta_data_query
      @sd_meta_data_query = SdMetaDataQuery.find params[:id]
    end
end
