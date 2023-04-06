class FundingSourcesController < ApplicationController
  def index
    @funding_sources = FundingSource.by_query_and_page(params[:q], params[:page])
  end
end
