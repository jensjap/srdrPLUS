class FundingSourcesController < ApplicationController
  def index
    @funding_sources = FundingSource.by_query(params[:q])
  end
end
