class FundingSourcesController < ApplicationController
  DEFAULT_FUNDING_SOURCES = [
    "PubMed / MEDLINE",
    "Embase",
    "Cochrane CENTRAL",
    "CINAHL"]
  def index
    if params[:q]
      @funding_sources = FundingSource.by_query(params[:q])
    else
      @funding_sources = []
      @funding_sources << FundingSource.find_or_create_by(name: DEFAULT_FUNDING_SOURCES[0])
      @funding_sources << FundingSource.find_or_create_by(name: DEFAULT_FUNDING_SOURCES[1])
      @funding_sources << FundingSource.find_or_create_by(name: DEFAULT_FUNDING_SOURCES[2])
      @funding_sources << FundingSource.find_or_create_by(name: DEFAULT_FUNDING_SOURCES[3])
    end
  end
end
