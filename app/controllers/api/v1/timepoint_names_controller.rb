class Api::V1::TimepointNamesController < Api::V1::BaseController
  before_action :skip_policy_scope, :skip_authorization

  def index
    @page  = params[:page]
    @query = params[:q]
    @timepoint_names = TimepointName
      .by_query(@query)
  end
end
