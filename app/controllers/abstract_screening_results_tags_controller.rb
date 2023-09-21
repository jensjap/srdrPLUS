class AbstractScreeningResultsTagsController < ApplicationController
  def create
    tag = Tag.find_or_create_by(id: params[:tag_id])
    abstract_screening_results_tag =
      AbstractScreeningResultsTag.find_or_create_by(
        abstract_screening_result_id: params[:abstract_screening_result_id], tag:
      )
    render json: abstract_screening_results_tag, status: 200
  end

  def destroy
    abstract_screening_results_tag = AbstractScreeningResultsTag.find(params[:id])
    abstract_screening_results_tag.destroy
    render json: abstract_screening_results_tag, status: 200
  end
end
