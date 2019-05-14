class SdSearchDatabasesController < ApplicationController
  def index
    @sd_search_databases = SdSearchDatabase.by_query(params[:q])
  end
end
