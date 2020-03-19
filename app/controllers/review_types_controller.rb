class ReviewTypesController < ApplicationController
  DEFAULT_REVIEW_TYPES = [
    "Full",
    "Rapid",
    "Scoping"
  ].freeze

  def index
    if params[:q]
      @review_types = ReviewType.by_query(params[:q])
    else
      @review_types = []
      @review_types << ReviewType.find_or_create_by(name: DEFAULT_REVIEW_TYPES[0])
      @review_types << ReviewType.find_or_create_by(name: DEFAULT_REVIEW_TYPES[1])
      @review_types << ReviewType.find_or_create_by(name: DEFAULT_REVIEW_TYPES[2])
    end
  end
end
