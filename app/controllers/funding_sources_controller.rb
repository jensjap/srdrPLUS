class FundingSourcesController < ApplicationController
  DEFAULT_FUNDING_SOURCES = [
    "AHRQ"]
  def index
    if params[:q]
      @funding_sources = FundingSource.by_query(params[:q])
    else
      @funding_sources = []
      @funding_sources << FundingSource.find_or_create_by(name: DEFAULT_FUNDING_SOURCES[0])
    end
  end
end
