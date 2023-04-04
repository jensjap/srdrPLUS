class SdSearchDatabasesController < ApplicationController
  DEFAULT_SD_SEARCH_DATABASES = [
    'PubMed / MEDLINE',
    'Embase',
    'Cochrane CENTRAL',
    'CINAHL'
  ]
  def index
    @sd_search_databases = SdSearchDatabase.by_query_and_page(params[:q], params[:page])
  end

  def create
    sd_search_database = SdSearchDatabase.find_or_create_by(sd_search_database_params)
    render json: sd_search_database.as_json, status: 200
  end

  private

  def sd_search_database_params
    params.permit(:name)
  end
end
