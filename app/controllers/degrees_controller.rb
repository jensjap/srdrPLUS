class DegreesController < ApplicationController
  def index
    @degrees = Degree.by_query(params[:q])
  end
end

