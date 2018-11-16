class DegreesController < ApplicationController
  # GET /degrees
  # GET /degrees.json
  def index
    skip_policy_scope
    authorize(Degree)

    @degrees = Degree.by_query(params[:q])
  end
end
