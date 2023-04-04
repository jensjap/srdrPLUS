class ReviewTypesController < ApplicationController
  DEFAULT_REVIEW_TYPES = %w[
    Full
    Rapid
    Scoping
  ].freeze

  def index
    @review_types = ReviewType.by_query_and_page(params[:q], params[:page])
  end

  def create
    review_type = ReviewType.find_or_create_by(name: params[:name])
    render json: { id: review_type.id }, status: 200
  end
end
