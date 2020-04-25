class SdSearchDatabasesController < ApplicationController
  DEFAULT_SD_SEARCH_DATABASES = [
    "PubMed / MEDLINE",
    "Embase",
    "Cochrane CENTRAL",
    "CINAHL"]
  def index
    if params[:q]
      @sd_search_databases = SdSearchDatabase.by_query(params[:q])
    else
      @sd_search_databases = []
      @sd_search_databases << SdSearchDatabase.find_or_create_by(name: DEFAULT_SD_SEARCH_DATABASES[0])
      @sd_search_databases << SdSearchDatabase.find_or_create_by(name: DEFAULT_SD_SEARCH_DATABASES[1])
      @sd_search_databases << SdSearchDatabase.find_or_create_by(name: DEFAULT_SD_SEARCH_DATABASES[2])
      @sd_search_databases << SdSearchDatabase.find_or_create_by(name: DEFAULT_SD_SEARCH_DATABASES[3])
    end
  end
end
