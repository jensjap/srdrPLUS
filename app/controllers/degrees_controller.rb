class DegreesController < ApplicationController
  before_action :skip_policy_scope, :skip_authorization

  # GET /degrees
  # GET /degrees.json
  def index
    @degrees = Degree.by_query(params[:q])
  end
end
