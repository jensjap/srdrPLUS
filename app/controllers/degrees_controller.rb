class DegreesController < ApplicationController
  # GET /degrees
  # GET /degrees.json
  def index
    @degrees = Degree.by_query(params[:q])
  end
end

